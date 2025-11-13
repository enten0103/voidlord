import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'permission_service.dart';
import '../apis/client.dart';
import '../apis/auth_api.dart';
import '../models/login_response.dart';

class AuthService extends GetxService {
  final loggedIn = false.obs;
  final lastError = RxnString();
  final userId = RxnInt();
  static const _kTokenKey = 'auth_token';
  String? _token;

  String? get token => _token;

  Future<AuthService> init() async {
    if (Get.testMode) return this; // 测试环境不访问本地存储
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString(_kTokenKey);
    if (t != null && t.isNotEmpty) {
      _token = t;
      Get.find<Api>().setBearerToken(_token);
      loggedIn.value = true;
      // 恢复登录后立即尝试加载权限
      if (Get.isRegistered<PermissionService>()) {
        await Get.find<PermissionService>().load();
      }
    }
    return this;
  }

  Future<bool> login(String username, String password) async {
    lastError.value = null;
    if (Get.testMode) {
      if (username.isNotEmpty && password.isNotEmpty) {
        loggedIn.value = true;
        return true;
      }
      lastError.value = '用户名或密码错误';
      return false;
    }

    try {
      final LoginResponse data = await Get.find<Api>().login(
        username: username,
        password: password,
      );
      if (data.accessToken.isNotEmpty) {
        _token = data.accessToken;
        Get.find<Api>().setBearerToken(_token);
        try {
          final sp = await SharedPreferences.getInstance();
          await sp.setString(_kTokenKey, _token!);
        } catch (_) {}
        if (Get.isRegistered<PermissionService>()) {
          await Get.find<PermissionService>().load();
        }
        loggedIn.value = true;
        userId.value = data.user.id;
        return true;
      }
      lastError.value = '登录失败';
      return false;
    } on AuthApiError catch (e) {
      Get.log('AuthApiError: ${e.message}');
      lastError.value = e.message;
      return false;
    } catch (e) {
      lastError.value = '未知错误';
      return false;
    }
  }

  Future<void> logout() async {
    loggedIn.value = false;
    _token = null;
    Get.find<Api>().setBearerToken(null);
    if (!Get.testMode) {
      try {
        final sp = await SharedPreferences.getInstance();
        await sp.remove(_kTokenKey);
      } catch (_) {}
    }
  }
}
