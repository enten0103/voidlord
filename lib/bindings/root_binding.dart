import 'package:get/get.dart';
import 'package:voidlord/pages/media_libraries/media_libraries_controller.dart';
import 'package:voidlord/pages/upload/upload_list_controller.dart';
import 'package:voidlord/pages/recommendations/recommendations_controller.dart';
import 'package:voidlord/pages/search/book_search_controller.dart';
import '../controllers/root_controller.dart';
import '../pages/permissions/permissions_controller.dart';
import '../pages/profile/profile_controller.dart';
import '../services/media_libraries_service.dart';
import 'package:voidlord/pages/square/square_controller.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RootController>(() => RootController());
    Get.lazyPut<PermissionsController>(() => PermissionsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<MediaLibrariesService>(() => MediaLibrariesService());
    Get.lazyPut<MediaLibrariesController>(() => MediaLibrariesController());
    Get.lazyPut<UploadListController>(() => UploadListController());
    Get.lazyPut<RecommendationsController>(() => RecommendationsController());
    Get.lazyPut<SquareController>(() => SquareController());
    Get.lazyPut<BookSearchController>(() => BookSearchController());
  }
}
