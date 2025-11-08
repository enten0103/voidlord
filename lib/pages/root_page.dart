import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../widgets/app_title_bar.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return Scaffold(
      appBar: AppTitleBar(
        title: '应用主体',
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            onPressed: () {
              auth.logout();
              Get.offAllNamed(Routes.login);
            },
            icon: const Icon(Icons.logout),
            tooltip: '退出登录',
          )
        ],
      ),
      body: Center(
        child: Text('应用主体', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
