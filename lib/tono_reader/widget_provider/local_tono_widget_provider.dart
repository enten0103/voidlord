import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/model/widget/tono_image.dart';
import 'package:voidlord/tono_reader/model/widget/tono_ruby.dart';
import 'package:voidlord/tono_reader/model/widget/tono_text.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/widget_provider/tono_widget_provider.dart';

class LocalTonoWidgetProvider extends TonoWidgetProvider {
  final Map<String, TonoWidget> widgets;
  final Map<String, Uint8List> images;
  final Map<String, Uint8List> fonts;
  final String hash;

  LocalTonoWidgetProvider({
    required this.widgets,
    required this.images,
    required this.fonts,
    required this.hash,
  });

  @override
  Future<TonoWidget> getWidgetsById(String id) async {
    var result = widgets[id];
    if (result == null) {
      throw Exception("cannot find widgets by id:$id");
    }
    return result;
  }

  @override
  Future<Uint8List> getAssetsById(String id) async {
    var result = images[id];
    if (result == null) {
      throw Exception("cannot find assets by id:$id");
    }
    return result;
  }

  @override
  Future<Map<String, Uint8List>> getAllFont() async {
    Map<String, Uint8List> result = {};
    for (var asset in fonts.entries) {
      result[asset.key] = asset.value;
    }
    return result;
  }

  Future saveAssets() async {
    // 简单互斥，避免并发保存
    if (_saving) return;
    _saving = true;
    final baseDir = await getApplicationDocumentsDirectory();
    final hashDir = Directory(p.join(baseDir.path, "book", hash, "assets"));

    // 创建 hash 目录（如果不存在）
    if (!await hashDir.exists()) {
      await hashDir.create(recursive: true);
    }

    // 保存所有资源文件
    final imageRoot = Directory(p.join(hashDir.path, "image"));
    if (await imageRoot.exists()) {
      await imageRoot.delete(recursive: true);
    }
    for (final entry in images.entries) {
      final filePath = p.join(hashDir.path, "image", entry.key);
      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(entry.value);
    }

    // 保存所有资源文件
    final fontRoot = Directory(p.join(hashDir.path, "font"));
    if (await fontRoot.exists()) {
      await fontRoot.delete(recursive: true);
    }
    for (final entry in fonts.entries) {
      final filePath = p.join(hashDir.path, "font", entry.key);
      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(entry.value);
    }
    _saving = false;
  }

  static Future<List<Map<String, Uint8List>>> loadAssets(String hash) async {
    final baseDir = await getApplicationDocumentsDirectory();

    final hashDir = Directory(p.join(baseDir.path, "book", hash, "assets"));
    // 检查目录是否存在
    if (!await hashDir.exists()) {
      throw Exception('No assets found for hash: $hash');
    }
    // 加载资源文件
    final assetsMap = <String, Uint8List>{};
    var imageDir = Directory(p.join(hashDir.path, "image"));
    if (await imageDir.exists()) {
      final imageFiles = await imageDir.list(recursive: true).toList();
      for (final entity in imageFiles) {
        if (entity is File) {
          assetsMap[p.basenameWithoutExtension(entity.path)] =
              await entity.readAsBytes();
        }
      }
    }

    final fontsMap = <String, Uint8List>{};
    var fontDir = Directory(p.join(hashDir.path, "font"));
    if (await fontDir.exists()) {
      final fontsFiles = await fontDir.list(recursive: true).toList();
      for (final entity in fontsFiles) {
        if (entity is File) {
          fontsMap[p.basenameWithoutExtension(entity.path)] =
              await entity.readAsBytes();
        }
      }
    }

    return [assetsMap, fontsMap];
  }

  @override
  Future<Map<String, dynamic>> toMap() async {
    await saveAssets();
    return {
      '_type': 'LocalTonoWidgetProvider', // 类型标识符用于反序列化
      'widgets': widgets.map((k, v) => MapEntry(k, v.toMap())),
      'hash': hash,
    };
  }

  static Future<LocalTonoWidgetProvider> fromMap(
      Map<String, dynamic> map) async {
    var assets = await loadAssets(map['hash']);
    var result = LocalTonoWidgetProvider(
      widgets: (map['widgets'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, TonoWidget.fromMap(v)),
      ),
      images: assets[0],
      fonts: assets[1],
      hash: map['hash'],
    );
    for (var widget in result.widgets.values) {
      addParent(widget, null);
    }
    return result;
  }

  static void addParent(TonoWidget tw, TonoWidget? parent) {
    if (tw is TonoRuby || tw is TonoImage || tw is TonoText) {
      tw.parent = parent;
    } else if (tw is TonoContainer) {
      tw.parent = parent;
      for (var child in tw.children) {
        if (child == tw.children.last) {
          child.extra['last'] = true;
        }
        addParent(child, tw);
      }
    }
  }
}

// 简易进程内互斥标记
bool _saving = false;
