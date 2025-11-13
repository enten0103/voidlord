import 'package:get/get.dart';
import '../controllers/root_controller.dart';
import '../pages/upload/upload_controller.dart';
import '../pages/permissions/permissions_controller.dart';
import '../pages/profile/profile_controller.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    // 根控制器
    Get.lazyPut<RootController>(() => RootController(), fenix: true);
    // 其他页面控制器（按需重建）
    Get.lazyPut<UploadController>(() => UploadController(), fenix: true);
    Get.lazyPut<PermissionsController>(() => PermissionsController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
