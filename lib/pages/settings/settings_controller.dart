import 'package:get/get.dart';
import '../../services/theme_service.dart';

class SettingsController extends GetxController {
  late final ThemeService themeService;

  @override
  void onInit() {
    super.onInit();
    themeService = Get.find<ThemeService>();
  }
}
