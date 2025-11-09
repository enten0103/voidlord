import 'package:get/get.dart';
import '../apis/permission_api.dart';
import '../apis/client.dart';

class PermissionService extends GetxService {
  // permission name -> level
  final RxMap<String, int> levels = <String, int>{}.obs;

  static const bookCreate = 'BOOK_CREATE';
  static const bookUpdate = 'BOOK_UPDATE';
  static const bookDelete = 'BOOK_DELETE';

  // 是否具备上传页访问资格（3 个权限均达到 >=1）
  RxBool get hasBookUploadAccess => RxBool(
    (levels[bookCreate] ?? 0) >= 1 &&
        (levels[bookUpdate] ?? 0) >= 1 &&
        (levels[bookDelete] ?? 0) >= 1,
  );

  Future<void> load() async {
    if (Get.testMode) {
      levels.clear();
      return;
    }
    try {
      final entries = await api.listMyPermissions();
      final map = <String, int>{};
      for (final e in entries) {
        map[e.permission] = e.level;
      }
      levels.assignAll(map);
    } catch (_) {
      // 静默失败
    }
  }
}
