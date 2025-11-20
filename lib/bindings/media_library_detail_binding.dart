import 'package:get/get.dart';
import 'package:voidlord/pages/media_libraries/media_library_detail_controller.dart';

class MediaLibraryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaLibraryDetailController>(
      () => MediaLibraryDetailController(),
    );
  }
}
