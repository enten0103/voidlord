import 'package:get/get.dart';
import '../config/app_environment.dart';

class BackendService extends GetxService {
  late final String baseUrl;

  BackendService() {
    baseUrl = AppEnvironment.baseUrl;
  }

  // Example request builder (no real HTTP here)
  Uri buildUri(String path, {Map<String, String>? query}) {
    return Uri.parse(baseUrl).replace(path: path, queryParameters: query);
  }
}
