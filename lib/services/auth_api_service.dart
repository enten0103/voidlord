import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../config/app_environment.dart';
import 'config_service.dart';

class AuthApiService extends GetxService {
  late final Dio _dio;
  late final String _baseUrl;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<ConfigService>()) {
      _baseUrl = Get.find<ConfigService>().baseUrl;
    } else {
      _baseUrl = AppEnvironment.baseUrl;
    }
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: { 'Content-Type': 'application/json' },
    ));
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'Unexpected response',
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      // 统一错误信息
      final status = e.response?.statusCode;
      if (status == 400) {
        throw AuthApiError('请求不合法，请检查输入');
      }
      if (status == 401) {
        throw AuthApiError('用户名或密码错误');
      }
      if (status == 409) {
        throw AuthApiError('用户名或邮箱已存在');
      }
      throw AuthApiError('网络错误，请稍后重试');
    } catch (_) {
      throw AuthApiError('发生未知错误');
    }
  }
}

class AuthApiError implements Exception {
  final String message;
  AuthApiError(this.message);
  @override
  String toString() => message;
}
