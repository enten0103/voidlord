import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voidlord/tono_reader/data_provider/tono_data_provider.dart';

class LocalDataProvider extends TonoDataProvider {
  LocalDataProvider({required this.root});
  final String root;

  final Map<String, Uint8List> _fileMap = {};
  late String _hash;
  Future init() async {
    _hash = await getFileHash(root);
    await loadFile(root);
  }

  String _normalizePath(String input) {
    if (input.isEmpty) return input;
    // 统一为 zip 内的 POSIX 风格，避免 Windows 反斜杠查找失败
    var s = input.replaceAll('\\', '/');
    while (s.startsWith('./')) {
      s = s.substring(2);
    }
    // 去重多余的 /
    while (s.contains('//')) {
      s = s.replaceAll('//', '/');
    }
    return s;
  }

  Future<String> getFileHash(String filePath) async {
    final file = File(filePath);
    final fileBytes = file.readAsBytesSync().buffer.asUint8List();
    final hash = md5.convert(fileBytes.buffer.asUint8List()).toString();
    return hash;
  }

  @override
  String get hash => _hash;

  @override
  Future<Uint8List?> getFileByPath(String path) async {
    final key = _normalizePath(path);
    return _fileMap[key];
  }

  Future loadFile(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    var baseUrl = "${(await getApplicationDocumentsDirectory()).path}/local";
    var hash = md5.convert(bytes).toString();
    var fileDirPath = '$baseUrl/$hash';
    var fileDir = Directory(fileDirPath);
    if (await fileDir.exists()) {
      await fileDir.delete(recursive: true);
    }
    for (final entry in archive) {
      if (entry.isFile) {
        _fileMap[_normalizePath(entry.name)] = entry.readBytes()!;
      }
    }
  }
}
