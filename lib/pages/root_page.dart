import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/pages/profile/profile_view.dart';
import 'package:voidlord/services/permission_service.dart';
import 'upload/upload_list_page.dart';
import 'permissions/permissions_page.dart';
import 'media_libraries/media_libraries_page.dart';
import 'package:voidlord/widgets/responsive_scaffold.dart';
import 'package:voidlord/controllers/root_controller.dart';

class RootPage extends GetView<RootController> {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final perm = Get.find<PermissionService>();
    // 断点逻辑已抽取到 ResponsiveScaffold，可在调用处覆写

    return Obx(() {
      final i = controller.index.value;
      final hasUpload = perm.hasBookUploadAccess.value;
      final hasPermMgmt = perm.canManagePermissions.value;
      final titles = [
        '广场',
        '搜索',
        '收藏',
        if (hasUpload) '上传',
        if (hasPermMgmt) '权限',
        '我的',
      ];
      // 确保控制器已注册（RootBinding 中注册 Service 后此处只需懒加载页面控制器）
      final pages = [
        const _SquareTab(),
        const _SearchTab(),
        const MediaLibrariesPage(),
        if (hasUpload) const UploadListPage(),
        if (hasPermMgmt) const PermissionsPage(),
        const ProfileView(),
      ];

      return ResponsiveScaffold(
        title: titles[i],
        actions: const [],
        pages: pages,
        items: [
          const NavItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            label: '广场',
          ),
          const NavItem(icon: Icons.search, label: '搜索'),
          const NavItem(
            icon: Icons.collections_bookmark_outlined,
            selectedIcon: Icons.collections_bookmark,
            label: '媒体库',
          ),
          if (hasUpload)
            const NavItem(
              icon: Icons.cloud_upload_outlined,
              selectedIcon: Icons.cloud_upload,
              label: '上传',
            ),
          if (hasPermMgmt)
            const NavItem(
              icon: Icons.admin_panel_settings_outlined,
              selectedIcon: Icons.admin_panel_settings,
              label: '权限',
            ),
          const NavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: '我的',
          ),
        ],
        selectedIndex: i,
        onSelected: controller.switchTab,
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
