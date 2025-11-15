import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/pages/profile/profile_view.dart';
import 'package:voidlord/services/permission_service.dart';
import 'upload/upload_list_page.dart';
import 'root/square_controller.dart';
import '../routes/app_routes.dart';
import 'recommendations/recommendations_page.dart';
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
      final hasRecommend = perm.canManageRecommendations.value;
      final titles = [
        '广场',
        '搜索',
        '收藏',
        if (hasUpload) '上传',
        if (hasPermMgmt) '权限',
        if (hasRecommend) '推荐',
        '我的',
      ];
      // 确保控制器已注册（RootBinding 中注册 Service 后此处只需懒加载页面控制器）
      final pages = [
        const _SquareTab(),
        const _SearchTab(),
        const MediaLibrariesPage(),
        if (hasUpload) const UploadListPage(),
        if (hasPermMgmt) const PermissionsPage(),
        if (hasRecommend) const RecommendationsPage(),
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
          if (hasRecommend)
            const NavItem(
              icon: Icons.recommend_outlined,
              selectedIcon: Icons.recommend,
              label: '推荐',
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

class _SquareTab extends GetView<SquareController> {
  const _SquareTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.error.value != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.error.value!),
              const SizedBox(height: 12),
              FilledButton(onPressed: controller.load, child: const Text('重试')),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('广场', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('应用主体', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            ...controller.sections.map(
              (sec) => Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          sec.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!sec.active)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Chip(
                            label: const Text('未启用'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sec.mediaLibraryName ?? '未关联媒体库',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (sec.description != null &&
                          sec.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            sec.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: '打开关联媒体库',
                    icon: const Icon(Icons.open_in_new),
                    onPressed: sec.mediaLibraryId == 0
                        ? null
                        : () => Get.toNamed(
                            '${Routes.mediaLibraryDetail}/${sec.mediaLibraryId}',
                            arguments: sec.mediaLibraryId,
                          ),
                  ),
                ),
              ),
            ),
            if (controller.sections.isEmpty)
              Text('暂无推荐分区', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    });
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
