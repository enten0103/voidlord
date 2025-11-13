import 'package:get/get.dart';
import '../pages/profile/profile_edit_view.dart';

class ProfileEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileEditController>(() => ProfileEditController(), fenix: true);
  }
}
