import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../../services/auth_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Obx(() {
      if (c.loading.value) {
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
                          c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                          ? NetworkImage(c.avatarUrl!)
                          : null,
                      child: (c.avatarUrl == null || c.avatarUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.displayName, style: textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(c.bio, style: textTheme.bodyMedium),
                          if (c.error.value != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              c.error.value!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
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
                      label: const Text('编辑资料'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed('/settings'),
                      icon: const Icon(Icons.settings),
                      label: const Text('设置'),
                    ),
                    OutlinedButton.icon(
                      key: const Key('logoutButton'),
                      onPressed: () async {
                        await Get.find<AuthService>().logout();
                        Get.offAllNamed('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('退出登录'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _infoCard(
                  children: [
                    _kv('界面主题', _themeLabel(c.theme)),
                    _kv('语言', c.locale),
                    _kv('时区', c.timezone),
                    _kv('邮件通知', c.emailNotifications ? '开启' : '关闭'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
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
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
