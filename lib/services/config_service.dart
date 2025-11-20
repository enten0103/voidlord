import 'package:get/get.dart';
import 'package:voidlord/config/app_config_dev.dart';
import 'package:voidlord/config/app_config_release.dart';
import '../config/app_config.dart';

class ConfigService extends GetxService {
  late final AppConfig config = const bool.fromEnvironment('dart.vm.product')
      ? ReleaseConfig
      : DevConfig;

  String get baseUrl => config.baseUrl;

  String get minioUrl => config.minioUrl;
}
