import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../apis/client.dart';
import '../../apis/user_config_api.dart';
import '../../widgets/side_baner.dart';
import 'profile_controller.dart';

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
        data = await Get.find<Api>().getMyConfig();
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
      await Get.find<Api>().updateMyConfig(payload);
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

  String? _nonnull(String? s) => (s != null && s.trim().isNotEmpty) ? s.trim() : null;

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
