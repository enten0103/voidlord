import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'config/app_environment.dart';
import 'services/auth_service.dart';
import 'services/config_service.dart';

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
  Get.put<AuthService>(AuthService(), permanent: true);
}
