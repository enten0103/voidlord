import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';

import 'package:voidlord/tono_reader/data_provider/local_data_provider.dart';
import 'package:voidlord/tono_reader/data_provider/tono_data_provider.dart';
import 'package:voidlord/tono_reader/model/base/tono.dart';
import 'package:voidlord/tono_reader/parser/tono_container_xml.dart';
import 'package:voidlord/tono_reader/parser/tono_opf_parser.dart';
import 'package:voidlord/tono_reader/parser/tono_parse_event.dart';
import 'package:voidlord/tono_reader/tool/tono_serializer.dart';

///tono解析器
///解析epub文件为tono文件
class TonoParser {
  TonoParser();

  late TonoDataProvider provider;

  // 广播进度事件
  final StreamController<TonoParseEvent> _controller =
      StreamController<TonoParseEvent>.broadcast();

  // 可选：后台解析用的 isolate 引用，便于取消
  Isolate? _runningIsolate;

  Stream<TonoParseEvent> get events => _controller.stream;

  void emit(TonoParseEvent e) {
    if (!_controller.isClosed) {
      _controller.add(e);
    }
  }

  Future<void> cancel() async {
    _runningIsolate?.kill(priority: Isolate.immediate);
    _runningIsolate = null;
    await _controller.close();
  }

  Future<Tono> parse() async {
    final rootFilePath = await parseContainerXml();
    final tono = await parseOpf(rootFilePath);
    return tono;
  }

  static Future<TonoParser> initFromDisk(String filePath) async {
    final provider = LocalDataProvider(root: filePath);
    final tp = TonoParser();
    await provider.init();
    tp.provider = provider;
    return tp;
  }

  // ============ 兼容旧 API（废弃）============
  @Deprecated(
    'Use initFromDisk(filePath) and subscribe to parser.events instead',
  )
  static Future<TonoParser> initFormDisk(
    String filePath,
    void Function(TonoParseEvent) onStateChange,
  ) async {
    final parser = await initFromDisk(filePath);
    // 兼容桥接：把事件转发给旧回调（注意：调用方应尽快迁移）
    parser.events.listen(onStateChange);
    return parser;
  }

  Future<String> parseInBackgroundAndSave() async {
    final receive = ReceivePort();
    final token = RootIsolateToken.instance;
    final args = _IsolateArgs(
      filePath: (provider is LocalDataProvider)
          ? (provider as LocalDataProvider).root
          : null,
      sendPort: receive.sendPort,
      token: token,
    );
    if (args.filePath == null) {
      throw StateError('Background parse only supports LocalDataProvider');
    }

    _runningIsolate = await Isolate.spawn<_IsolateArgs>(
      _parseAndSaveIsolateEntry,
      args,
      paused: false,
    );

    final completer = Completer<String>();
    late StreamSubscription sub;
    sub = receive.listen((message) {
      if (message is Map) {
        if (message['type'] == 'event') {
          final e = TonoParseEvent(
            info: message['info'] as String? ?? '',
            currentIndex: message['current'] as int? ?? 0,
            totalIndex: message['total'] as int? ?? 0,
          );
          emit(e);
        } else if (message['type'] == 'done') {
          final hash = message['hash']?.toString() ?? '';
          completer.complete(hash);
          sub.cancel();
          receive.close();
          _runningIsolate = null;
        } else if (message['type'] == 'error') {
          completer.completeError(
            Exception(message['message'] ?? 'unknown error'),
          );
          sub.cancel();
          receive.close();
          _runningIsolate = null;
        }
      }
    });

    return completer.future;
  }

  /// 在后台 Isolate 解析并直接返回 Tono（不做落地保存）
  Future<Tono> parseInBackground() async {
    final receive = ReceivePort();
    final token = RootIsolateToken.instance;
    final args = _IsolateArgs(
      filePath: (provider is LocalDataProvider)
          ? (provider as LocalDataProvider).root
          : null,
      sendPort: receive.sendPort,
      token: token,
    );
    if (args.filePath == null) {
      throw StateError('Background parse only supports LocalDataProvider');
    }

    _runningIsolate = await Isolate.spawn<_IsolateArgs>(
      _parseAndReturnIsolateEntry,
      args,
      paused: false,
    );

    final completer = Completer<Tono>();
    late StreamSubscription sub;
    sub = receive.listen((message) async {
      if (message is Map) {
        if (message['type'] == 'event') {
          final e = TonoParseEvent(
            info: message['info'] as String? ?? '',
            currentIndex: message['current'] as int? ?? 0,
            totalIndex: message['total'] as int? ?? 0,
          );
          emit(e);
        } else if (message['type'] == 'done') {
          final map = message['map'] as Map<String, dynamic>;
          final tono = await Tono.fromMap(map);
          completer.complete(tono);
          await sub.cancel();
          receive.close();
          _runningIsolate = null;
        } else if (message['type'] == 'error') {
          completer.completeError(
            Exception(message['message'] ?? 'unknown error'),
          );
          await sub.cancel();
          receive.close();
          _runningIsolate = null;
        }
      }
    });

    return completer.future;
  }
}

class _IsolateArgs {
  final String? filePath;
  final SendPort sendPort;
  final RootIsolateToken? token;
  const _IsolateArgs({
    required this.filePath,
    required this.sendPort,
    this.token,
  });
}

// 后台解析入口：创建本地 provider，实例化解析器，转发事件，保存 tono
Future<void> _parseAndSaveIsolateEntry(_IsolateArgs args) async {
  final send = args.sendPort;
  try {
    // 初始化后台 Isolate 的 BinaryMessenger，用于支持插件/平台通道调用（如 path_provider）
    if (args.token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(args.token!);
    }
    final provider = LocalDataProvider(root: args.filePath!);
    await provider.init();
    // 在子 isolate 内部也构建一个解析器，但事件用 sendPort 转发为 Map
    final parser = TonoParser();
    parser.provider = provider;
    final sub = parser.events.listen((e) {
      send.send({
        'type': 'event',
        'info': e.info,
        'current': e.currentIndex,
        'total': e.totalIndex,
      });
    });

    final tono = await parser.parse();
    await TonoSerializer.save(tono);
    await sub.cancel();
    send.send({'type': 'done', 'hash': tono.hash});
  } catch (e) {
    send.send({'type': 'error', 'message': e.toString()});
  }
}

// 后台解析入口：解析并把 Tono 的 map 返回到主 isolate，不做保存
Future<void> _parseAndReturnIsolateEntry(_IsolateArgs args) async {
  final send = args.sendPort;
  try {
    if (args.token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(args.token!);
    }
    final provider = LocalDataProvider(root: args.filePath!);
    await provider.init();
    final parser = TonoParser();
    parser.provider = provider;
    final sub = parser.events.listen((e) {
      send.send({
        'type': 'event',
        'info': e.info,
        'current': e.currentIndex,
        'total': e.totalIndex,
      });
    });

    final tono = await parser.parse();
    final map = await tono.toMap();
    await sub.cancel();
    send.send({'type': 'done', 'map': map});
  } catch (e) {
    send.send({'type': 'error', 'message': e.toString()});
  }
}
