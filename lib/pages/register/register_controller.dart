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

  // 邮箱格式校验
  bool get emailFormatValid {
    final v = email.value.trim();
    if (v.isEmpty) return false;
    final reg = RegExp(r'^[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}$');
    return reg.hasMatch(v);
  }

  // 密码强度评分：长度>=8、数字、大小写、特殊字符
  int get passwordScore {
    final p = password.value;
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[a-z]').hasMatch(p)) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
    return score;
  }

  bool get passwordStrongEnough => passwordScore >= 3; // 至少中等

  String get passwordStrengthLabel {
    final s = passwordScore;
    if (s <= 2) return '弱';
    if (s <= 4) return '中';
    return '强';
  }

  Color passwordStrengthColor(BuildContext context) {
    final s = passwordScore;
    if (s <= 2) return Colors.redAccent;
    if (s <= 4) return Colors.orangeAccent;
    return Colors.green;
  }

  bool get valid =>
      username.value.isNotEmpty &&
      emailFormatValid &&
      password.value.length >= 6 &&
      password.value == confirm.value &&
      passwordStrongEnough;

  Future<void> submit() async {
    if (loading.value) return;
    if (!valid) {
      if (!emailFormatValid) {
        error.value = '邮箱格式不正确';
      } else if (password.value != confirm.value) {
        error.value = '两次密码不一致';
      } else if (password.value.length < 6) {
        error.value = '密码长度至少 6 位';
      } else if (!passwordStrongEnough) {
        error.value = '密码强度不足（需达到中等）';
      } else {
        error.value = '请填写完整信息';
      }
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
