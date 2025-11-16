import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/app_title_bar.dart';
import 'register_controller.dart';
import '../../routes/app_routes.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTitleBar(title: '注册'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Text('V', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('创建账号', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('填写以下信息以创建新账号', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    _field(
                      label: '用户名',
                      keyName: 'regUsernameField',
                      onChanged: (v) => controller.username.value = v,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: '邮箱',
                      keyName: 'regEmailField',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => controller.email.value = v,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: '密码',
                      keyName: 'regPasswordField',
                      obscure: true,
                      onChanged: (v) => controller.password.value = v,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: '确认密码',
                      keyName: 'regConfirmField',
                      obscure: true,
                      onChanged: (v) => controller.confirm.value = v,
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      final enabled = controller.valid && !controller.loading.value;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          key: const Key('registerSubmitButton'),
                          onPressed: enabled ? controller.submit : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: controller.loading.value
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('创建账号'),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.offAllNamed(Routes.login),
                      child: const Text('已有账号？转到登录'),
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

  Widget _field({
    required String label,
    required String keyName,
    bool obscure = false,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      key: Key(keyName),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      keyboardType: keyboardType,
      obscureText: obscure,
      onChanged: onChanged,
    );
  }
}