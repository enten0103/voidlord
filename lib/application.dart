import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/routes/app_pages.dart';
import 'package:voidlord/services/auth_service.dart';
import 'package:voidlord/services/theme_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    return Obx(
      () => GetMaterialApp(
        title: 'VoidLord Demo',
        debugShowCheckedModeBanner: false,
        theme: themeService.lightTheme,
        darkTheme: themeService.darkTheme,
        themeMode: themeService.mode.value,
        builder: (context, child) => child ?? const SizedBox.shrink(),
        initialRoute: Get.find<AuthService>().loggedIn.value
            ? AppPages.root
            : AppPages.login,
        getPages: AppPages.pages,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
