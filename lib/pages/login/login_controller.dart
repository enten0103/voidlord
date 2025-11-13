import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class LoginController extends GetxController {
  final username = ''.obs;
  final password = ''.obs;
  final loading = false.obs;
  final error = RxnString();

  AuthService get _auth => Get.find<AuthService>();

  Future<void> submit() async {
    if (loading.value) return;
    loading.value = true;
    error.value = null;
    final ok = await _auth.login(username.value, password.value);
    loading.value = false;
    if (ok) {
      Get.offAllNamed(Routes.root);
    } else {
      final msg = _auth.lastError.value ?? '登录失败，请检查用户名或密码';
      if (Get.isDialogOpen != true) {
        Get.dialog(
          AlertDialog(
            title: const Text('登录失败'),
            content: Text(msg),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('确定')),
            ],
          ),
          barrierDismissible: true,
        );
      }
    }
  }
}
