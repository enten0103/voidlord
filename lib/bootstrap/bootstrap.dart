import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../config/app_environment.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';
import '../services/config_service.dart';

/// Perform app pre-start initialization before runApp.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Compile-time env constants (access to trigger class loading)
  AppEnvironment.flavor;
  AppEnvironment.baseUrl;

  // Load layered config (json assets by flavor)
  if (!Get.isRegistered<ConfigService>()) {
    final configService = ConfigService();
    await configService.init();
    Get.put<ConfigService>(configService, permanent: true);
  }

  // Global services
  if (!Get.isRegistered<AuthService>()) {
    Get.put<AuthService>(AuthService(), permanent: true);
  }
  if (!Get.isRegistered<BackendService>()) {
    Get.put<BackendService>(BackendService(), permanent: true);
  }

  // Windows custom frame init (skip in tests to avoid native loading)
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
