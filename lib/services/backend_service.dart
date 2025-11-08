import 'package:get/get.dart';
import '../config/app_environment.dart';
import 'config_service.dart';

class BackendService extends GetxService {
  late final String baseUrl;

  BackendService() {
    // 优先使用文件配置，其次 fallback 到 dart-define 环境常量
    if (Get.isRegistered<ConfigService>()) {
      baseUrl = Get.find<ConfigService>().baseUrl;
    } else {
      baseUrl = AppEnvironment.baseUrl;
    }
  }

  // Example request builder (no real HTTP here)
  Uri buildUri(String path, {Map<String, String>? query}) {
    return Uri.parse(baseUrl).replace(path: path, queryParameters: query);
  }
}
