import 'package:get/get.dart';
import '../pages/profile/profile_edit_controller.dart';

class ProfileEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileEditController>(() => ProfileEditController());
  }
}
