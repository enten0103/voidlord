import 'dart:io';

import 'package:flutter/material.dart';
import '../../apis/client.dart';
import '../../apis/user_config_api.dart';
import 'profile_controller.dart';
import '../../widgets/side_baner.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';

class ProfileEditController extends GetxController {
  final loading = true.obs;
  final saving = false.obs;
  final error = RxnString();

  // 表单字段
  final displayNameCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final avatarUrlCtrl = TextEditingController();
  final localeCtrl = TextEditingController();
  final timezoneCtrl = TextEditingController();
  final theme = 'system'.obs;
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
      Map<String, dynamic> data;
      if (Get.testMode) {
        data = {
          'display_name': '测试用户',
          'bio': '这是测试简介',
          'avatar_url': null,
          'locale': 'zh-CN',
          'timezone': 'UTC',
          'theme': 'system',
          'email_notifications': true,
        };
      } else {
        data = await api.getMyConfig();
      }
      displayNameCtrl.text = data['display_name'] ?? '';
      bioCtrl.text = data['bio'] ?? '';
      avatarUrlCtrl.text = data['avatar_url'] ?? '';
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
      final payload = <String, dynamic>{
        'display_name': _nonnull(displayNameCtrl.text),
        'bio': _nonnull(bioCtrl.text),
        'avatar_url': _nonnull(avatarUrlCtrl.text),
        'locale': _nonnull(localeCtrl.text),
        'timezone': _nonnull(timezoneCtrl.text),
        'theme': theme.value,
        'email_notifications': emailNotifications.value,
      }..removeWhere((k, v) => v == null);
      await api.updateMyConfig(payload);
      SideBanner.info('个人配置已更新');
      Get.find<ProfileController>().onInit();
      Get.back();
    } catch (e) {
      error.value = '保存失败';
      SideBanner.danger('保存失败：$e');
    } finally {
      saving.value = false;
    }
  }

  String? _nonnull(String? s) =>
      (s != null && s.trim().isNotEmpty) ? s.trim() : null;

  @override
  void onClose() {
    displayNameCtrl.dispose();
    bioCtrl.dispose();
    avatarUrlCtrl.dispose();
    localeCtrl.dispose();
    timezoneCtrl.dispose();
    super.onClose();
  }
}

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  late final ProfileEditController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(ProfileEditController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        flexibleSpace:
            Platform.isWindows || Platform.isLinux || Platform.isMacOS
            ? DragToMoveArea(child: Container(color: Colors.transparent))
            : null,
      ),
      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _textField('展示名', c.displayNameCtrl, hint: '例如：Alice'),
              const SizedBox(height: 12),
              _textField('简介', c.bioCtrl, maxLines: 3, hint: '一句话介绍你自己'),
              const SizedBox(height: 12),
              _textField('头像URL', c.avatarUrlCtrl, hint: 'http(s)://'),
              const SizedBox(height: 12),
              _textField('语言', c.localeCtrl, hint: 'zh-CN'),
              const SizedBox(height: 12),
              _textField('时区', c.timezoneCtrl, hint: 'Asia/Shanghai'),
              const SizedBox(height: 12),
              _themeDropdown(),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('邮件通知'),
                value: c.emailNotifications.value,
                onChanged: (v) => c.emailNotifications.value = v,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: c.saving.value ? null : c.save,
                  icon: c.saving.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('保存'),
                ),
              ),
              if (c.error.value != null) ...[
                const SizedBox(height: 12),
                Text(
                  c.error.value!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _textField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    String? hint,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _themeDropdown() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: '主题',
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value: c.theme.value,
            items: const [
              DropdownMenuItem(value: 'system', child: Text('跟随系统')),
              DropdownMenuItem(value: 'light', child: Text('浅色')),
              DropdownMenuItem(value: 'dark', child: Text('深色')),
            ],
            onChanged: (v) => c.theme.value = v ?? 'system',
          ),
        ),
      ),
    );
  }
}
