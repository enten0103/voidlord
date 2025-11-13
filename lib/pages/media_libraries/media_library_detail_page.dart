import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'media_library_detail_controller.dart';

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
                  return _bookTile(context, b);
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

  Widget _bookTile(BuildContext context, BookTileData b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: _buildCover(b.cover),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          b.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          b.author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildCover(String? value) {
    if (value == null) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.book, size: 32, color: Colors.black45),
        ),
      );
    }
    final isUrl = value.startsWith('http://') || value.startsWith('https://');
    final src = isUrl ? value : 'http://localhost:9000/voidlord/$value';
    return Image.network(
      src,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
    );
  }
}
