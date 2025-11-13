import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../../services/auth_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Get.theme.textTheme;
    return GetBuilder<ProfileController>(
      builder: (controller) {
        return Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              controller.avatarUrl != null &&
                                  controller.avatarUrl!.isNotEmpty
                              ? NetworkImage(controller.avatarUrl!)
                              : null,
                          child:
                              (controller.avatarUrl == null ||
                                  controller.avatarUrl!.isEmpty)
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.displayName,
                                style: textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(controller.bio, style: textTheme.bodyMedium),
                              if (controller.error.value != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  controller.error.value!,
                                  style: TextStyle(
                                    color: Get.theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => Get.toNamed('/profile/edit'),
                          icon: const Icon(Icons.edit),
                          label: const Text('资料'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Get.toNamed('/settings'),
                          icon: const Icon(Icons.settings),
                          label: const Text('设置'),
                        ),
                        OutlinedButton.icon(
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                              Get.theme.colorScheme.error,
                            ),
                            side: WidgetStateProperty.all(
                              BorderSide(color: Get.theme.colorScheme.error),
                            ),
                          ),
                          key: const Key('logoutButton'),
                          onPressed: () async {
                            await Get.find<AuthService>().logout();
                            Get.offAllNamed('/login');
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('登出'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _infoCard(
                      children: [
                        _kv('界面主题', _themeLabel(controller.theme)),
                        _kv('语言', controller.locale),
                        _kv('时区', controller.timezone),
                        _kv(
                          '邮件通知',
                          controller.emailNotifications ? '开启' : '关闭',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  String _themeLabel(String v) {
    switch (v) {
      case 'light':
        return '浅色';
      case 'dark':
        return '深色';
      default:
        return '跟随系统';
    }
  }

  Widget _infoCard({required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 24),
              children[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: Get.theme.textTheme.labelMedium),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: Get.theme.textTheme.bodyMedium)),
      ],
    );
  }
}
