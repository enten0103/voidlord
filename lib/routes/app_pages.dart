import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/login/login_view.dart';
import '../bindings/login_binding.dart';
import '../pages/root_page.dart';
import '../bindings/root_binding.dart';
import '../pages/profile/profile_edit_view.dart';
import '../pages/settings/settings_view.dart';
import '../bindings/profile_edit_binding.dart';
import '../bindings/settings_binding.dart';
import '../services/auth_service.dart';
import '../pages/media_libraries/media_library_detail_page.dart';
import '../pages/upload/upload_page.dart';
import '../pages/upload/upload_list_page.dart';
import '../pages/book/book_detail_page.dart';
import '../bindings/book_detail_binding.dart';
import '../bindings/media_library_detail_binding.dart';
import '../bindings/upload_binding.dart';
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
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.root,
      page: () => const RootPage(),
      middlewares: [AuthMiddleware()],
      binding: RootBinding(),
    ),
    GetPage(
      name: Routes.profileEdit,
      page: () => const ProfileEditView(),
      middlewares: [AuthMiddleware()],
      binding: ProfileEditBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      middlewares: [AuthMiddleware()],
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.mediaLibraryDetail,
      page: () => const MediaLibraryDetailPage(),
      middlewares: [AuthMiddleware()],
      binding: MediaLibraryDetailBinding(),
    ),
    GetPage(
      name: Routes.uploadList,
      page: () => const UploadListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.uploadEdit,
      page: () => const UploadPage(),
      middlewares: [AuthMiddleware()],
      binding: UploadBinding(),
    ),
    GetPage(
      name: Routes.bookDetail,
      page: () => const BookDetailPage(),
      middlewares: [AuthMiddleware()],
      binding: BookDetailBinding(),
    ),
  ];

  static const login = Routes.login;
  static const root = Routes.root;
}
