import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class RegisterController extends GetxController {
  final username = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final confirm = ''.obs;
  final loading = false.obs;
  final error = RxnString();

  AuthService get _auth => Get.find<AuthService>();

  bool get valid => username.value.isNotEmpty &&
      email.value.isNotEmpty &&
      password.value.length >= 6 &&
      password.value == confirm.value;

  Future<void> submit() async {
    if (loading.value) return;
    if (!valid) {
      error.value = '请填写完整信息并确保两次密码一致 (≥6 位)';
      _showError();
      return;
    }
    loading.value = true;
    error.value = null;
    final ok = await _auth.register(
      username.value.trim(),
      email.value.trim(),
      password.value,
    );
    loading.value = false;
    if (ok) {
      Get.offAllNamed(Routes.root);
    } else {
      error.value = _auth.lastError.value ?? '注册失败';
      _showError();
    }
  }

  void _showError() {
    final msg = error.value;
    if (msg == null) return;
    if (Get.isDialogOpen != true) {
      Get.dialog(
        AlertDialog(
          title: const Text('提示'),
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