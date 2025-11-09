import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/services/auth_service.dart';
import 'services/theme_service.dart';

import 'routes/app_pages.dart';
import 'bootstrap.dart';

void main() async {
  await bootstrap();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    final loggedIn = Get.find<AuthService>().loggedIn;
    return Obx(
      () => GetMaterialApp(
        title: 'VoidLord Demo',
        debugShowCheckedModeBanner: false,
        theme: themeService.lightTheme,
        darkTheme: themeService.darkTheme,
        themeMode: themeService.mode.value,
        builder: (context, child) => child ?? const SizedBox.shrink(),
        initialRoute: loggedIn.value ? AppPages.root : AppPages.login,
        getPages: AppPages.pages,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
