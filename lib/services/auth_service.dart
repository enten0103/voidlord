import 'package:get/get.dart';

class AuthService extends GetxService {
  final loggedIn = false.obs;

  Future<bool> login(String username, String password) async {
    // 简单模拟：非空即成功
    if (username.isNotEmpty && password.isNotEmpty) {
      loggedIn.value = true;
      return true;
    }
    return false;
  }

  void logout() {
    loggedIn.value = false;
  }
}
