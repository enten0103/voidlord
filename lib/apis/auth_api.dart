import 'package:dio/dio.dart';
import 'client.dart';

extension AuthApi on Api {
  /// 调用后端登录接口
  /// 成功时返回后端 JSON Map（包含 access_token, user 等）
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final Response res = await client.post(
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
