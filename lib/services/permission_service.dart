import 'package:get/get.dart';
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
      // 测试环境默认无权限
      levels.clear();
      return;
    }
    try {
      final res = await api.client.get('/permissions/user/me');
      if (res.statusCode == 200 && res.data is List) {
        final List list = res.data as List;
        final map = <String, int>{};
        for (final item in list) {
          if (item is Map && item['permission'] is String) {
            final name = item['permission'] as String;
            final lv = (item['level'] is num)
                ? (item['level'] as num).toInt()
                : 0;
            map[name] = lv;
          }
        }
        levels.assignAll(map);
      }
    } catch (_) {
      // 静默失败，不影响主流程
    }
  }
}
