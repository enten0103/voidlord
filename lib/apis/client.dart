import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../services/config_service.dart';
import '../config/app_environment.dart';

class Api {
  final Dio client;
  String? _bearerToken; // 缓存的 token，拦截器使用

  Api()
    : client = Dio(
        BaseOptions(
          baseUrl: _resolveBaseUrl(),
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          headers: const {'Content-Type': 'application/json'},
        ),
      ) {
    client.options.validateStatus = (status) => true;
    // 请求拦截器：统一附加 Authorization（若存在）
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_bearerToken != null && _bearerToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${_bearerToken!}';
          } else {
            options.headers.remove('Authorization');
          }
          handler.next(options);
        },
      ),
    );
  }

  static String _resolveBaseUrl() {
    if (Get.isRegistered<ConfigService>()) {
      return Get.find<ConfigService>().baseUrl;
    }
    return AppEnvironment.baseUrl;
  }

  void setBearerToken(String? token) {
    _bearerToken = (token == null || token.isEmpty) ? null : token;
  }
}
