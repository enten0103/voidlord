import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../widgets/responsive_scaffold.dart';

class RootController extends GetxController {
  final index = 0.obs;

  void switchTab(int i) => index.value = i;
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final c = Get.put(RootController());
    final titles = ['广场', '搜索', '收藏', '我的'];
    final pages = const [
      _SquareTab(),
      _SearchTab(),
      _FavoritesTab(),
      _ProfileTab(),
    ];
    // 断点逻辑已抽取到 ResponsiveScaffold，可在调用处覆写

    return Obx(() {
      final i = c.index.value;
      return ResponsiveScaffold(
        title: titles[i],
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            onPressed: () {
              auth.logout();
              Get.offAllNamed(Routes.login);
            },
            icon: const Icon(Icons.logout),
            tooltip: '退出登录',
          ),
        ],
        pages: pages,
        items: const [
          NavItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            label: '广场',
          ),
          NavItem(icon: Icons.search, label: '搜索'),
          NavItem(
            icon: Icons.bookmark_outline,
            selectedIcon: Icons.bookmark,
            label: '收藏',
          ),
          NavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: '我的',
          ),
        ],
        selectedIndex: i,
        onSelected: c.switchTab,
      );
    });
  }
}

class _SquareTab extends StatelessWidget {
  const _SquareTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('广场', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          // 为了兼容现有测试，保留“应用主体”文案
          Text('应用主体', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('搜索', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('收藏', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('我的', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
