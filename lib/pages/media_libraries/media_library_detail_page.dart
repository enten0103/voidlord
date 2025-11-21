import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'media_library_detail_controller.dart';
import '../../widgets/book_tile.dart';
import '../../widgets/draggable_app_bar.dart';

class MediaLibraryDetailPage extends GetView<MediaLibraryDetailController> {
  const MediaLibraryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DraggableAppBar(
        title: Obx(() {
          if (controller.isSearchMode.value) {
            final t = controller.searchTitle.value;
            return Text(t != null ? '搜索: $t' : '搜索结果');
          }
          return Text(controller.library.value?.name ?? '媒体库');
        }),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: '排序',
            onSelected: controller.updateSort,
            itemBuilder: (context) {
              const options = {
                'id:desc': '最新添加',
                'id:asc': '最早添加',
                'title:asc': '标题 A-Z',
                'title:desc': '标题 Z-A',
                'created_at:desc': '最新创建',
                'created_at:asc': '最早创建',
              };
              return options.entries.map((e) {
                return CheckedPopupMenuItem(
                  value: e.key,
                  checked: controller.sort.value == e.key,
                  child: Text(e.value),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return Center(child: Text(controller.error.value!));
        }
        return Padding(
          padding: const EdgeInsets.all(12),
          child: CustomScrollView(
            slivers: [
              const SliverPadding(padding: EdgeInsets.only(top: 8)),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  childAspectRatio: 0.56,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final b = controller.books[index];
                  return BookTile(
                    title: b.title,
                    author: b.author,
                    cover: b.cover,
                    onTap: () => Get.toNamed('/book/${b.id}', arguments: b.id),
                  );
                }, childCount: controller.books.length),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Obx(() {
                      if (controller.loadingMore.value) {
                        return const SizedBox(
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
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
              if (controller.others.isNotEmpty) ...[
                const SliverPadding(padding: EdgeInsets.only(top: 24)),
                SliverToBoxAdapter(
                  child: Text(
                    '子库',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final item = controller.others[i];
                    return ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(
                        item.childLibrary?.name ??
                            '子库 #${item.childLibrary?.id ?? ''}',
                      ),
                    );
                  }, childCount: controller.others.length),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  // _bookTile 与 _buildCover 已用 BookTile 替换
}
