import 'package:get/get.dart';
import '../../apis/client.dart';
import '../../apis/user_config_api.dart';

class ProfileController extends GetxController {
  final loading = true.obs;
  final error = RxnString();
  final data = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      data.value = await Get.find<Api>().getMyConfig();
    } catch (e) {
      error.value = '加载失败';
    } finally {
      loading.value = false;
    }
  }

  String get displayName =>
      (data.value?['display_name'] as String?)?.trim().isNotEmpty == true
      ? data.value!['display_name'] as String
      : '未设置';

  String get bio => (data.value?['bio'] as String?)?.trim().isNotEmpty == true
      ? data.value!['bio'] as String
      : '暂无简介';

  String? get avatarUrl => data.value?['avatar_url'] as String?;
  String get locale => (data.value?['locale'] as String?) ?? 'zh-CN';
  String get timezone => (data.value?['timezone'] as String?) ?? 'UTC';
  String get theme => (data.value?['theme'] as String?) ?? 'system';
  bool get emailNotifications =>
      (data.value?['email_notifications'] as bool?) ?? true;
}
