import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'config/app_environment.dart';
import 'services/auth_service.dart';
import 'services/config_service.dart';
import 'services/theme_service.dart';
import 'services/permission_service.dart';
import 'services/image_cache_settings_service.dart';
import 'apis/client.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await initWindowsWindowSetup();
}

Future<void> initWindowsWindowSetup() async {
  if ((GetPlatform.isWindows || GetPlatform.isLinux || GetPlatform.isMacOS) &&
      !Get.testMode) {
    await windowManager.ensureInitialized();
    const initialSize = Size(1080, 720);
    const minSize = Size(400, 400);
    final options = const WindowOptions(
      size: initialSize,
      minimumSize: minSize,
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'VoidLord',
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

Future initDependencies() async {
  AppEnvironment.flavor;
  AppEnvironment.baseUrl;

  final configService = ConfigService();
  await configService.init();

  Get.put<ConfigService>(configService, permanent: true);
  // 注册 Api (需要在 auth 之前或之后均可，之后可以设置 token)
  final apiClient = Api();
  Get.put<Api>(apiClient, permanent: true);
  final auth = AuthService();
  await auth.init();
  Get.put<AuthService>(auth, permanent: true);
  // 如果恢复了 token，写入 Api 拦截器缓存
  final restoredToken = auth.token;
  if (restoredToken != null && restoredToken.isNotEmpty) {
    apiClient.setBearerToken(restoredToken);
  }
  final themeService = ThemeService();
  await themeService.init();
  Get.put<ThemeService>(themeService, permanent: true);

  // 图片缓存与质量设置服务
  final imgCacheService = ImageCacheSettingsService();
  await imgCacheService.init();
  Get.put<ImageCacheSettingsService>(imgCacheService, permanent: true);

  final permService = PermissionService();
  // 登录态如果已恢复则尝试加载权限
  if (auth.loggedIn.value) {
    await permService.load();
  }
  Get.put<PermissionService>(permService, permanent: true);
}
