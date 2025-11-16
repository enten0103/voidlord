import 'package:get/get.dart';
import '../config/app_environment.dart';
import '../config/app_config.dart';

class ConfigService extends GetxService {
  late final AppConfig config;

  Future<ConfigService> init() async {
    final flavor = AppEnvironment.flavor;
    config = await loadAppConfig(flavor);
    return this;
  }

  String get baseUrl => config.baseUrl;

  String get minioUrl => config.minioUrl;
}
