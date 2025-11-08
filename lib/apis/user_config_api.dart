import 'package:dio/dio.dart';
import 'client.dart';

class UserConfigApiError implements Exception {
  final String message;
  final int? statusCode;
  UserConfigApiError(this.message, {this.statusCode});
  @override
  String toString() => 'UserConfigApiError($statusCode): $message';
}

extension UserConfigApi on Api {
  Future<Map<String, dynamic>> getMyConfig() async {
    final Response res = await client.get('/user-config/me');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw UserConfigApiError('获取用户配置失败', statusCode: res.statusCode);
  }

  Future<Map<String, dynamic>> updateMyConfig(
    Map<String, dynamic> payload,
  ) async {
    final Response res = await client.patch('/user-config/me', data: payload);
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw UserConfigApiError('更新用户配置失败', statusCode: res.statusCode);
  }
}
