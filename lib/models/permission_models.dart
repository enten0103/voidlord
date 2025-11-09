/// 权限名称常量（与后端枚举保持一致）
class PermissionName {
  PermissionName._();
  static const userRead = 'USER_READ';
  static const userCreate = 'USER_CREATE';
  static const userUpdate = 'USER_UPDATE';
  static const userDelete = 'USER_DELETE';
  static const bookRead = 'BOOK_READ';
  static const bookCreate = 'BOOK_CREATE';
  static const bookUpdate = 'BOOK_UPDATE';
  static const bookDelete = 'BOOK_DELETE';
  static const recommendationManage = 'RECOMMENDATION_MANAGE';
  static const fileManage = 'FILE_MANAGE';
  static const commentManage = 'COMMENT_MANAGE';
  static const sysManage = 'SYS_MANAGE';

  static const all = <String>{
    userRead,
    userCreate,
    userUpdate,
    userDelete,
    bookRead,
    bookCreate,
    bookUpdate,
    bookDelete,
    recommendationManage,
    fileManage,
    commentManage,
    sysManage,
  };
}

/// 用户权限条目：permission + level
class UserPermissionEntry {
  final String permission;
  final int level; // 0~3 (通常接口只返回已授予 >=1)

  const UserPermissionEntry({required this.permission, required this.level});

  factory UserPermissionEntry.fromJson(Map<String, dynamic> json) {
    return UserPermissionEntry(
      permission: json['permission'] as String,
      level: (json['level'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {'permission': permission, 'level': level};
}

/// 授予权限请求 DTO
class GrantPermissionRequest {
  final int userId;
  final String permission;
  final int level; // 1,2,3
  const GrantPermissionRequest({
    required this.userId,
    required this.permission,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'permission': permission,
    'level': level,
  };
}

/// 撤销权限请求 DTO
class RevokePermissionRequest {
  final int userId;
  final String permission;
  const RevokePermissionRequest({
    required this.userId,
    required this.permission,
  });

  Map<String, dynamic> toJson() => {'userId': userId, 'permission': permission};
}

class PermissionApiError implements Exception {
  final String message;
  final int? statusCode;
  PermissionApiError(this.message, {this.statusCode});
  @override
  String toString() => 'PermissionApiError($statusCode): $message';
}
