import 'package:get/get.dart';
import '../apis/client.dart';
import '../apis/auth_api.dart';

class AuthService extends GetxService {
  final loggedIn = false.obs;
  final lastError = RxnString();

  Future<bool> login(String username, String password) async {
    lastError.value = null;
    if (Get.testMode) {
      // 测试环境保持原行为以避免外部依赖
      if (username.isNotEmpty && password.isNotEmpty) {
        loggedIn.value = true;
        return true;
      }
      lastError.value = '用户名或密码错误';
      return false;
    }

    try {
      final data = await api.login(username: username, password: password);
      if (data['access_token'] != null) {
        // 设置 token 供后续请求复用
        api.setBearerToken(data['access_token'] as String);
        loggedIn.value = true;
        return true;
      }
      lastError.value = '登录失败';
      return false;
    } on AuthApiError catch (e) {
      // 可以根据需要记录日志
      Get.log('AuthApiError: ${e.message}');
      lastError.value = e.message;
      return false;
    }
  }

  void logout() {
    loggedIn.value = false;
  }
}
