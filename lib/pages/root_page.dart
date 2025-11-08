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
        title: 'root_title',
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            onPressed: () {
              auth.logout();
              Get.offAllNamed(Routes.login);
            },
            icon: const Icon(Icons.logout),
            tooltip: 'logout'.tr,
          )
        ],
      ),
      body: Center(
        child: Text('root_title'.tr, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
