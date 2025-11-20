import 'package:path/path.dart' as path;

extension PathTool on String {
  String pathSplicing(String relativePath) {
    // 先将 Windows 分隔符转换为 POSIX，便于与 zip 内部路径匹配
    String normalize(String p) {
      var s = p.replaceAll('\\\\', '/').replaceAll('\\', '/');
      while (s.contains('//')) {
        s = s.replaceAll('//', '/');
      }
      while (s.startsWith('./')) {
        s = s.substring(2);
      }
      return s;
    }

    var currentDir = path.dirname(this);
    relativePath = normalize(relativePath);
    while (relativePath.startsWith("../")) {
      relativePath = relativePath.substring(3);
      currentDir = path.dirname(currentDir);
    }
    final joined = path.join(currentDir, relativePath);
    return normalize(joined);
  }
}
