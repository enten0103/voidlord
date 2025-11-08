import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../widgets/responsive_scaffold.dart';
import '../apis/client.dart';

class RootController extends GetxController {
  final index = 0.obs;

  void switchTab(int i) => index.value = i;
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RootController());
    final auth = Get.find<AuthService>();
    final titles = ['广场', '搜索', '收藏', '我的'];
    final pages = const [
      _SquareTab(),
      _SearchTab(),
      _FavoritesTab(),
      _ProfileTab(),
    ];
    // 断点逻辑已抽取到 ResponsiveScaffold，可在调用处覆写

    return Obx(() {
      final i = controller.index.value;
      return ResponsiveScaffold(
        title: titles[i],
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            onPressed: () {
              auth.logout();
              Get.offAllNamed(Routes.login);
            },
            icon: const Icon(Icons.logout),
            tooltip: '退出登录',
          ),
        ],
        pages: pages,
        items: const [
          NavItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            label: '广场',
          ),
          NavItem(icon: Icons.search, label: '搜索'),
          NavItem(
            icon: Icons.bookmark_outline,
            selectedIcon: Icons.bookmark,
            label: '收藏',
          ),
          NavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: '我的',
          ),
        ],
        selectedIndex: i,
        onSelected: controller.switchTab,
      );
    });
  }
}

class _SquareTab extends StatelessWidget {
  const _SquareTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('广场', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          // 为了兼容现有测试，保留“应用主体”文案
          Text('应用主体', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('搜索', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('收藏', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const _MyProfileView();
  }
}

class _MyProfileController extends GetxController {
  final loading = true.obs;
  final saving = false.obs;
  final error = RxnString();

  // 表单字段
  final displayNameCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final avatarUrlCtrl = TextEditingController();
  final avatarKeyCtrl = TextEditingController();
  final localeCtrl = TextEditingController();
  final timezoneCtrl = TextEditingController();
  final theme = 'system'.obs; // system/light/dark
  final emailNotifications = true.obs;


  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    error.value = null;
    try {
      final repo = _UserConfigRepo();
      final data = await repo.getMyConfig();
      displayNameCtrl.text = data['display_name'] ?? '';
      bioCtrl.text = data['bio'] ?? '';
      avatarUrlCtrl.text = data['avatar_url'] ?? '';
      avatarKeyCtrl.text = data['avatar_key'] ?? '';
      localeCtrl.text = data['locale'] ?? 'zh-CN';
      timezoneCtrl.text = data['timezone'] ?? 'UTC';
      theme.value = (data['theme'] ?? 'system') as String;
      emailNotifications.value = (data['email_notifications'] ?? true) as bool;
    } catch (e) {
      error.value = '加载失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> save() async {
    saving.value = true;
    error.value = null;
    try {
      final repo = _UserConfigRepo();
      final payload = <String, dynamic>{
        'display_name': _nonnull(displayNameCtrl.text),
        'bio': _nonnull(bioCtrl.text),
        'avatar_url': _nonnull(avatarUrlCtrl.text),
        'avatar_key': _nonnull(avatarKeyCtrl.text),
        'locale': _nonnull(localeCtrl.text),
        'timezone': _nonnull(timezoneCtrl.text),
        'theme': theme.value,
        'email_notifications': emailNotifications.value,
      }..removeWhere((k, v) => v == null);

      await repo.updateMyConfig(payload);
      Get.snackbar('已保存', '个人配置已更新', snackPosition: SnackPosition.BOTTOM);

      // 立即应用主题
      _applyTheme(theme.value);
    } catch (e) {
      error.value = '保存失败';
      Get.snackbar('保存失败', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      saving.value = false;
    }
  }

  void _applyTheme(String t) {
    switch (t) {
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      default:
        Get.changeThemeMode(ThemeMode.system);
    }
  }

  String? _nonnull(String? s) => (s != null && s.trim().isNotEmpty) ? s.trim() : null;
}

class _MyProfileView extends StatefulWidget {
  const _MyProfileView();

  @override
  State<_MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<_MyProfileView> {
  late final _MyProfileController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(_MyProfileController());
  }

  @override
  void dispose() {
    // 让 GetX 管理控制器生命周期，这里只处理 TextEditingController
    c.displayNameCtrl.dispose();
    c.bioCtrl.dispose();
    c.avatarUrlCtrl.dispose();
    c.avatarKeyCtrl.dispose();
    c.localeCtrl.dispose();
    c.timezoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeText = Theme.of(context).textTheme;
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
                      radius: 36,
                      backgroundImage: (c.avatarUrlCtrl.text.isNotEmpty)
                          ? NetworkImage(c.avatarUrlCtrl.text)
                          : null,
                      child: c.avatarUrlCtrl.text.isEmpty
                          ? const Icon(Icons.person, size: 36)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('我的资料', style: themeText.titleLarge),
                          if (c.error.value != null) ...[
                            const SizedBox(height: 4),
                            Text(c.error.value!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionCard(children: [
                  _textField(label: '展示名', controller: c.displayNameCtrl, hint: '例如：Alice'),
                  _textField(label: '简介', controller: c.bioCtrl, hint: '一句话介绍你自己', maxLines: 3),
                ]),
                const SizedBox(height: 12),
                _sectionCard(children: [
                  _textField(label: '头像 URL', controller: c.avatarUrlCtrl, hint: 'http(s)://...'),
                  _textField(label: '头像 Key', controller: c.avatarKeyCtrl, hint: 'avatars/<userId>.png'),
                ]),
                const SizedBox(height: 12),
                _sectionCard(children: [
                  _dropdownField(
                    label: '主题',
                    value: c.theme.value,
                    onChanged: (v) => c.theme.value = v ?? 'system',
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('跟随系统')),
                      DropdownMenuItem(value: 'light', child: Text('浅色')),
                      DropdownMenuItem(value: 'dark', child: Text('深色')),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('邮件通知'),
                    value: c.emailNotifications.value,
                    onChanged: (v) => c.emailNotifications.value = v,
                  ),
                ]),
                const SizedBox(height: 12),
                _sectionCard(children: [
                  _textField(label: '语言', controller: c.localeCtrl, hint: '例如：zh-CN'),
                  _textField(label: '时区', controller: c.timezoneCtrl, hint: '例如：Asia/Shanghai'),
                ]),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: c.saving.value ? null : c.save,
                    icon: c.saving.value
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: const Text('保存'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              children[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required ValueChanged<T?> onChanged,
    required List<DropdownMenuItem<T>> items,
  }) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: '主题',
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// 轻量数据层封装复用 api 扩展
class _UserConfigRepo {
  Future<Map<String, dynamic>> getMyConfig() async {
    final r = await api.client.get('/user-config/me');
    if (r.statusCode == 200 && r.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(r.data as Map);
    }
    throw Exception('Get my config failed: ${r.statusCode}');
  }

  Future<Map<String, dynamic>> updateMyConfig(Map<String, dynamic> dto) async {
    final r = await api.client.patch('/user-config/me', data: dto);
    if (r.statusCode == 200 && r.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(r.data as Map);
    }
    throw Exception('Update my config failed: ${r.statusCode}');
  }
}
