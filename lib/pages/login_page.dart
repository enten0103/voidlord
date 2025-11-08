import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../widgets/app_title_bar.dart';

class LoginController extends GetxController {
  final username = ''.obs;
  final password = ''.obs;
  final loading = false.obs;
  final error = RxnString();

  final _auth = Get.find<AuthService>();

  Future<void> submit() async {
    if (loading.value) return;
    loading.value = true;
  error.value = null;
    final ok = await _auth.login(username.value, password.value);
    loading.value = false;
    if (ok) {
      Get.offAllNamed(Routes.root);
    } else {
      error.value = '登录失败';
    }
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LoginController());
    return Scaffold(
      appBar: const AppTitleBar(title: '登录'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('usernameField'),
              decoration: const InputDecoration(labelText: '用户名'),
              onChanged: (v) => c.username.value = v,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('passwordField'),
              decoration: const InputDecoration(labelText: '密码'),
              obscureText: true,
              onChanged: (v) => c.password.value = v,
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
                  key: const Key('loginButton'),
                  onPressed: c.loading.value ? null : c.submit,
                  child: c.loading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('立即登录'),
                )),
            Obx(() => c.error.value == null
                ? const SizedBox.shrink()
                : Text(
                    c.error.value ?? '',
                    style: const TextStyle(color: Colors.red),
                  ))
          ],
        ),
      ),
    );
  }
}
