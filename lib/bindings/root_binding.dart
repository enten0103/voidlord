import 'package:get/get.dart';
import '../controllers/root_controller.dart';
import '../pages/upload/upload_controller.dart';
import '../pages/permissions/permissions_controller.dart';
import '../pages/profile/profile_controller.dart';
import '../services/media_libraries_service.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RootController>(() => RootController());
    Get.lazyPut<UploadController>(() => UploadController());
    Get.lazyPut<PermissionsController>(() => PermissionsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<MediaLibrariesService>(() => MediaLibrariesService(), fenix: true);
  }
}
