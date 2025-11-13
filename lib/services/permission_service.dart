import 'package:get/get.dart';
import '../apis/permission_api.dart';
import '../apis/client.dart';

class PermissionService extends GetxService {
  // permission name -> level
  final RxMap<String, int> levels = <String, int>{}.obs;

  // Derived reactive flags
  final hasBookUploadAccess = false.obs;
  final canManagePermissions = false.obs;

  static const bookCreate = 'BOOK_CREATE';
  static const bookUpdate = 'BOOK_UPDATE';
  static const bookDelete = 'BOOK_DELETE';

  @override
  void onInit() {
    super.onInit();
    _recompute();
    // Recompute whenever levels map changes
    ever<Map<String, int>>(levels, (_) => _recompute());
  }

  void _recompute() {
    hasBookUploadAccess.value =
        (levels[bookCreate] ?? 0) >= 1 &&
        (levels[bookUpdate] ?? 0) >= 1 &&
        (levels[bookDelete] ?? 0) >= 1;
    canManagePermissions.value = levels.values.any((l) => l >= 3);
  }

  Future<void> load() async {
    if (Get.testMode) {
      levels.clear();
      return _recompute();
    }
    try {
      final entries = await Get.find<Api>().listMyPermissions();
      final map = <String, int>{};
      for (final e in entries) {
        map[e.permission] = e.level;
      }
      levels.assignAll(map); // triggers ever -> _recompute
    } catch (_) {
      // 静默失败
    }
  }
}
