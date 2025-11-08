import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../services/config_service.dart';
import '../config/app_environment.dart';

class Api {
  final Dio client;

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
    // 保持与旧行为一致：全部状态码交给调用方判断
    client.options.validateStatus = (status) => true;
  }

  static String _resolveBaseUrl() {
    if (Get.isRegistered<ConfigService>()) {
      return Get.find<ConfigService>().baseUrl;
    }
    return AppEnvironment.baseUrl;
  }

  void setBearerToken(String? token) {
    if (token == null || token.isEmpty) {
      client.options.headers.remove('Authorization');
    } else {
      client.options.headers['Authorization'] = 'Bearer $token';
    }
  }
}

// 便捷单例
final Api api = Api();
