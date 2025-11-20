import 'dart:typed_data';

abstract class TonoDataProvider {
  // 通过路径获取文件
  Future<Uint8List?> getFileByPath(String path);
  // 获取hash
  String get hash;
}
