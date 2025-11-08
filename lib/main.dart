import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'routes/app_pages.dart';
import 'bootstrap/bootstrap.dart';

void main() async {
  await bootstrap();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VoidLord Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      builder: (context, child) {
        // 包裹一个 WindowBorder 仅 Windows 下生效，测试模式下禁用
        if (GetPlatform.isWindows && !Get.testMode) {
          return WindowBorder(
            color: Colors.indigo.withValues(alpha: 0.4),
            width: 1,
            child: child ?? const SizedBox.shrink(),
          );
        }
        return child ?? const SizedBox.shrink();
      },
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
