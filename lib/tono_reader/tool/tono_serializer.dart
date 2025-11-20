import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:voidlord/tono_reader/model/base/tono.dart';

class TonoSerializer {
  static _saveTono(Tono tono, Directory hashDir) async {
    final map = await tono.toMap();
    var result = json.encoder.convert(map);
    final filePath = p.join(hashDir.path, "tono.json");
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(result);
  }

  static _saveBaseInfo(Tono tono, Directory hashDir) async {
    final map = tono.bookInfo.toMap();
    var result = json.encoder.convert(map);
    final filePath = p.join(hashDir.path, "info.json");
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(result);
  }

  /// 序列化 Tono
  static save(Tono tono) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final hashDir = Directory(p.join(baseDir.path, "book", tono.hash));
    if (await hashDir.exists()) {
      // 确保彻底清理，避免与 assets 写入并发导致的目录非空错误
      await hashDir.delete(recursive: true);
    }

    await _saveTono(tono, hashDir);
    await _saveBaseInfo(tono, hashDir);
  }

  /// 反序列化 Tono 对象
  static Future<Tono> deserialize(String hash) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final hashDir = Directory(p.join(baseDir.path, "book", hash));
    final filePath = p.join(hashDir.path, "tono.json");
    final file = File(filePath);

    // 检查文件是否存在
    if (!await file.exists()) {
      throw FileSystemException('Tono file not found', filePath);
    }

    try {
      // 读取并解码 JSON
      final str = await file.readAsString();
      final dynamic jsonData = json.decode(str);

      // 验证 JSON 结构
      if (jsonData is! Map<String, dynamic>) {
        throw FormatException('Invalid root type, expected Map');
      }

      // 创建 Tono 对象
      return Tono.fromMap(jsonData);
    } on FormatException catch (e) {
      throw FormatException(
          'JSON decoding failed: ${e.message}', e.source, e.offset);
    } catch (e) {
      throw Exception('Deserialization failed: ${e.toString()}');
    }
  }
}
