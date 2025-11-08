import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 注册全局服务
  Get.put<AuthService>(AuthService(), permanent: true);
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
