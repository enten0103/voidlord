import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../models/book_models.dart';
import 'upload_list_controller.dart';
import '../../apis/client.dart';
import '../../apis/books_api.dart';
import '../../widgets/side_baner.dart';

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
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 180, // 宽屏时自动增加列数
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.56, // 稍增高度避免文本溢出
                          ),
                      itemCount: controller.books.length,
                      itemBuilder: (context, index) {
                        final b = controller.books[index];
                        return _bookTile(context, b);
                      },
                    );
                  },
                ),
        );
      }),
    );
  }

  Widget _bookTile(BuildContext context, BookDto b) {
    final tagsMap = {for (final t in b.tags) t.key.toUpperCase(): t.value};
    final cover = tagsMap['COVER'];
    final title = tagsMap['TITLE'] ?? '未命名';
    final author = tagsMap['AUTHOR'] ?? '-';

    return InkWell(
      onTap: () => Get.toNamed(Routes.bookDetail, arguments: b.id),
      onLongPress: () async {
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
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: cover == null
                  ? Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.book,
                          size: 32,
                          color: Colors.black45,
                        ),
                      ),
                    )
                  : Image.network(
                      'http://localhost:9000/voidlord/$cover',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey.shade300),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
