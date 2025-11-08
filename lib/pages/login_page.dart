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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 顶部标识与标题
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: const Text(
                            'V',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '欢迎登录',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '请使用账号密码登录',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 输入区域（填充式、圆角）
                    TextField(
                      key: const Key('usernameField'),
                      decoration: InputDecoration(
                        labelText: '用户名',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (v) => c.username.value = v,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('passwordField'),
                      decoration: InputDecoration(
                        labelText: '密码',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      obscureText: true,
                      onChanged: (v) => c.password.value = v,
                    ),
                    const SizedBox(height: 20),

                    // 登录按钮（全宽）
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          key: const Key('loginButton'),
                          onPressed: c.loading.value ? null : c.submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: c.loading.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('立即登录'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // 错误信息
                    Obx(
                      () => c.error.value == null
                          ? const SizedBox.shrink()
                          : Text(
                              c.error.value ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
