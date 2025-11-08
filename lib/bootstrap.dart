import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'config/app_environment.dart';
import 'services/auth_service.dart';
import 'services/backend_service.dart';
import 'services/config_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await initWindowsWindowSetup();
}

Future<void> initWindowsWindowSetup() async {
  if (GetPlatform.isWindows && !Get.testMode) {
    doWhenWindowReady(() {
      final win = appWindow;
      const initialSize = Size(1000, 680);
      win.minSize = const Size(800, 560);
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.title = 'VoidLord';
      win.show();
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
  Get.put<BackendService>(BackendService(), permanent: true);
}
