import 'package:dio/dio.dart';
import 'client.dart';
import '../models/login_response.dart';

extension AuthApi on Api {
  /// 调用后端登录接口
  /// 成功时返回强类型 LoginResponse（包含 access_token, user 等）
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final Response res = await client.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data is Map<String, dynamic>) {
        return LoginResponse.fromJson(res.data as Map<String, dynamic>);
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
      // /auth/login 不应返回 409，但为稳健保留处理
      if (status == 409) throw AuthApiError('用户名或邮箱已存在');
      throw AuthApiError('网络错误，请稍后重试');
    } catch (e) {
      throw AuthApiError('发生未知错误');
    }
  }

  /// 调用后端注册接口：成功后直接返回登录态结构
  Future<LoginResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final Response res = await client.post(
        '/auth/register',
        data: {'username': username, 'email': email, 'password': password},
      );
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data is Map<String, dynamic>) {
        return LoginResponse.fromJson(res.data as Map<String, dynamic>);
      }
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'Unexpected response',
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400) throw AuthApiError('请求不合法，请检查输入');
      if (status == 409) throw AuthApiError('用户名或邮箱已存在');
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
