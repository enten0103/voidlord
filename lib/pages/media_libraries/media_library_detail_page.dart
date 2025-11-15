import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'media_library_detail_controller.dart';
import '../../widgets/book_tile.dart';

class MediaLibraryDetailPage extends GetView<MediaLibraryDetailController> {
  const MediaLibraryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => DragToMoveArea(
            child: Text(controller.library.value?.name ?? '媒体库'),
          ),
        ),
        flexibleSpace:
            Platform.isWindows || Platform.isLinux || Platform.isMacOS
            ? DragToMoveArea(child: Container(color: Colors.transparent))
            : null,
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
