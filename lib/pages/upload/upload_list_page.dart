import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../models/book_models.dart';
import 'upload_list_controller.dart';
import '../../apis/client.dart';
import '../../apis/books_api.dart';
import '../../widgets/side_baner.dart';
import '../../widgets/adaptive_book_grid.dart';

class UploadListPage extends GetView<UploadListController> {
  const UploadListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Platform.isWindows
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'refreshFab',
                  tooltip: '刷新',
                  onPressed: controller.load,
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'addFab',
                  tooltip: '新建图书',
                  onPressed: () => Get.toNamed(Routes.uploadEdit),
                  child: const Icon(Icons.add),
                ),
              ],
            )
          : FloatingActionButton(
              tooltip: '新建图书',
              onPressed: () => Get.toNamed(Routes.uploadEdit),
              child: const Icon(Icons.add),
            ),
      body: Obx(() {
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
                FilledButton(
                  onPressed: controller.load,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: controller.books.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Text(
                        '暂无上传的图书，点击右下角 + 进行创建',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                )
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    AdaptiveBookSliverGrid(
                      books: controller.books,
                      onTap: (b) => Get.toNamed(Routes.bookDetail, arguments: b.id),
                      onLongPress: (b) => _onTileLongPress(context, b),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Center(
                          child: Obx(() {
                            if (controller.loadingMore.value) {
                              return const SizedBox(
                                height: 40,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            if (controller.noMore.value) {
                              return Text(
                                '已加载全部 (${controller.books.length})',
                                style: Theme.of(context).textTheme.labelSmall,
                              );
                            }
                            return OutlinedButton.icon(
                              onPressed: controller.loadMore,
                              icon: const Icon(Icons.more_horiz),
                              label: const Text('加载更多'),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      }),
    );
  }

  void _onTileLongPress(BuildContext context, BookDto b) async {
  // 标签解析逻辑已在网格组件中处理，这里不再使用本地变量，仅保留方法签名
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('删除'),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('取消'),
              onTap: () => Navigator.pop(ctx, 'cancel'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (action == 'edit') {
      Get.toNamed(Routes.uploadEdit, arguments: b.id);
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dctx) => AlertDialog(
          title: const Text('确认删除'),
          content: Text('删除图书 #${b.id}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dctx, true),
              child: const Text('删除'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        try {
          final api = Get.find<Api>();
          final ok = await api.deleteBook(b.id);
          if (ok) {
            controller.books.removeWhere((e) => e.id == b.id);
            SideBanner.info('已删除 #${b.id}');
          } else {
            SideBanner.danger('删除失败');
          }
        } catch (e) {
          SideBanner.danger('删除异常');
        }
      }
    }
  }
}
