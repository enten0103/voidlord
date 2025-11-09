import 'package:dio/dio.dart';
import 'client.dart';
import '../models/permission_models.dart';

extension PermissionApi on Api {
  /// 当前登录用户的权限列表 /permissions/user/me
  Future<List<UserPermissionEntry>> listMyPermissions() async {
    final Response res = await client.get('/permissions/user/me');
    if (res.statusCode == 200 && res.data is List) {
      final list = res.data as List;
      return list
          .whereType<Map>()
          .map(
            (e) => UserPermissionEntry.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
    throw PermissionApiError('获取权限失败', statusCode: res.statusCode);
  }

  /// 获取指定用户权限 /permissions/user/:id
  Future<List<UserPermissionEntry>> listUserPermissions(int userId) async {
    final Response res = await client.get('/permissions/user/$userId');
    if (res.statusCode == 200 && res.data is List) {
      final list = res.data as List;
      return list
          .whereType<Map>()
          .map(
            (e) => UserPermissionEntry.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
    throw PermissionApiError('获取用户权限失败', statusCode: res.statusCode);
  }

  /// 授予权限 /permissions/grant
  Future<UserPermissionEntry> grantPermission(
    GrantPermissionRequest req,
  ) async {
    final Response res = await client.post(
      '/permissions/grant',
      data: req.toJson(),
    );
    if ((res.statusCode == 200 || res.statusCode == 201) &&
        res.data is Map<String, dynamic>) {
      return UserPermissionEntry.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    }
    final code = res.statusCode;
    switch (code) {
      case 400:
        throw PermissionApiError('请求不合法', statusCode: code);
      case 401:
        throw PermissionApiError('未登录', statusCode: code);
      case 403:
        throw PermissionApiError('权限不足', statusCode: code);
      case 409:
        throw PermissionApiError('冲突：可能已存在或级别不允许', statusCode: code);
    }
    throw PermissionApiError('授予失败', statusCode: code);
  }

  /// 撤销权限 /permissions/revoke
  Future<bool> revokePermission(RevokePermissionRequest req) async {
    final Response res = await client.post(
      '/permissions/revoke',
      data: req.toJson(),
    );
    if ((res.statusCode == 200 || res.statusCode == 201) &&
        res.data is Map<String, dynamic>) {
      final map = Map<String, dynamic>.from(res.data as Map);
      return map['revoked'] == true;
    }
    final code = res.statusCode;
    switch (code) {
      case 400:
        throw PermissionApiError('请求不合法', statusCode: code);
      case 401:
        throw PermissionApiError('未登录', statusCode: code);
      case 403:
        throw PermissionApiError('权限不足', statusCode: code);
    }
    throw PermissionApiError('撤销失败', statusCode: code);
  }
}
