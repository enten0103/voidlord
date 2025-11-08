import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'routes/app_pages.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 注册全局服务
  Get.put<AuthService>(AuthService(), permanent: true);
  runApp(const MyApp());
  // Windows 自定义窗口初始化
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
        // 包裹一个 WindowBorder 仅 Windows 下生效，其他平台忽略
        return WindowBorder(
          color: Colors.indigo.withValues(alpha: 0.4),
          width: 1,
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      translations: _SimpleTranslations(),
      locale: const Locale('zh', 'CN'),
    );
  }
}

// 简单的国际化示例（可后续扩展）
class _SimpleTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': {
          'login': '登录',
          'username': '用户名',
          'password': '密码',
          'login_action': '立即登录',
          'root_title': '应用主体',
          'logout': '退出登录',
        },
        'en_US': {
          'login': 'Login',
          'username': 'Username',
          'password': 'Password',
          'login_action': 'Sign In',
          'root_title': 'Root Page',
          'logout': 'Logout',
        }
      };
}
