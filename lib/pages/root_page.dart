import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../widgets/app_title_bar.dart';

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
    const double railBreakpoint = 800; // ≥800 使用侧边导航
    const double railExtendedBreakpoint = 1200; // ≥1200 展开显示文字

    return Obx(() {
      final i = c.index.value;
      final width = MediaQuery.of(context).size.width;
      final useRail = width >= railBreakpoint;
      final railExtended = width >= railExtendedBreakpoint;

      if (useRail) {
        return Scaffold(
          appBar: AppTitleBar(
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
          ),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  selectedIndex: i,
                  onDestinationSelected: c.switchTab,
                  groupAlignment: -1,
                  extended: railExtended,
                  labelType: railExtended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: Text('广场'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search),
                      label: Text('搜索'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bookmark_outline),
                      selectedIcon: Icon(Icons.bookmark),
                      label: Text('收藏'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('我的'),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pages[i]),
            ],
          ),
        );
      }

      // 窄屏：底部导航
      return Scaffold(
        appBar: AppTitleBar(
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
        ),
        body: pages[i],
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: c.switchTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: '广场',
            ),
            NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: '收藏',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
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
