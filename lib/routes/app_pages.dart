import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/login_page.dart';
import '../pages/root_page.dart';
import '../services/auth_service.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();
    if (!auth.loggedIn.value && route != Routes.login) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
}

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        // 在进入 login 路由时注入 LoginController
      }),
    ),
    GetPage(
      name: Routes.root,
      page: () => const RootPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];

  static const initial = Routes.login;
}
