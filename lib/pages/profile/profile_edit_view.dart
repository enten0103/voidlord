import 'dart:io';

import 'package:flutter/material.dart';
import 'profile_edit_controller.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';

class ProfileEditView extends GetView<ProfileEditController> {
  const ProfileEditView({super.key});

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
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _textField('展示名', controller.displayNameCtrl, hint: '例如：Alice'),
              const SizedBox(height: 12),
              _textField(
                '简介',
                controller.bioCtrl,
                maxLines: 3,
                hint: '一句话介绍你自己',
              ),
              const SizedBox(height: 12),
              _textField('头像URL', controller.avatarUrlCtrl, hint: 'http(s)://'),
              const SizedBox(height: 12),
              _textField('语言', controller.localeCtrl, hint: 'zh-CN'),
              const SizedBox(height: 12),
              _textField('时区', controller.timezoneCtrl, hint: 'Asia/Shanghai'),
              const SizedBox(height: 12),
              _themeDropdown(controller),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('邮件通知'),
                value: controller.emailNotifications.value,
                onChanged: (v) => controller.emailNotifications.value = v,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.saving.value ? null : controller.save,
                  icon: controller.saving.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('保存'),
                ),
              ),
              if (controller.error.value != null) ...[
                const SizedBox(height: 12),
                Text(
                  controller.error.value!,
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

  Widget _themeDropdown(ProfileEditController controller) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: '主题',
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value: controller.theme.value,
            items: const [
              DropdownMenuItem(value: 'system', child: Text('跟随系统')),
              DropdownMenuItem(value: 'light', child: Text('浅色')),
              DropdownMenuItem(value: 'dark', child: Text('深色')),
            ],
            onChanged: (v) => controller.theme.value = v ?? 'system',
          ),
        ),
      ),
    );
  }
}
