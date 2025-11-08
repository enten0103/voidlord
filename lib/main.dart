import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'routes/app_pages.dart';
import 'services/auth_service.dart';
import 'services/backend_service.dart';
import 'config/app_environment.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化构建环境配置（读取 dart-define 常量）
  // 因为值是编译期常量，这里只是访问触发类加载
  AppEnvironment.flavor;
  AppEnvironment.baseUrl;

  // 注册全局服务
  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<BackendService>(BackendService(), permanent: true);
  runApp(const MyApp());
  // Windows 自定义窗口初始化（测试模式下关闭以避免加载原生库）
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
