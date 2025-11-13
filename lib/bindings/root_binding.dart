import 'package:get/get.dart';
import 'package:voidlord/pages/media_libraries/media_libraries_controller.dart';
import 'package:voidlord/pages/upload/upload_list_controller.dart';
import '../controllers/root_controller.dart';
import '../pages/permissions/permissions_controller.dart';
import '../pages/profile/profile_controller.dart';
import '../services/media_libraries_service.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RootController>(() => RootController());
    Get.lazyPut<PermissionsController>(() => PermissionsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<MediaLibrariesService>(() => MediaLibrariesService());
    Get.lazyPut<MediaLibrariesController>(() => MediaLibrariesController());
    Get.lazyPut<UploadListController>(() => UploadListController());
  }
}
