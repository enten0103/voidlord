import 'package:get/get.dart';
import 'auth_api_service.dart';

class AuthService extends GetxService {
  final loggedIn = false.obs;

  Future<bool> login(String username, String password) async {
    if (Get.testMode) {
      // 测试环境保持原行为以避免外部依赖
      if (username.isNotEmpty && password.isNotEmpty) {
        loggedIn.value = true;
        return true;
      }
      return false;
    }

    final api = Get.put<AuthApiService>(AuthApiService(), permanent: true);
    try {
      final data = await api.login(username: username, password: password);
      if (data['access_token'] != null) {
        loggedIn.value = true;
        return true;
      }
      return false;
    } on AuthApiError catch (e) {
      // 可以根据需要记录日志
      Get.log('AuthApiError: ${e.message}');
      return false;
    }
  }

  void logout() {
    loggedIn.value = false;
  }
}
