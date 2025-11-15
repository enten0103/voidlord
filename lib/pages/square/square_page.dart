import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/models/book_models.dart';
import '../../widgets/book_tile.dart';
import 'square_controller.dart';

class SquarePage extends GetView<SquareController> {
  const SquarePage({super.key});

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
        onRefresh: () async => controller.load(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final sec in controller.sections) _sectionCard(context, sec),
            if (controller.sections.isEmpty)
              Text('暂无推荐分区', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    });
  }

  Widget _sectionCard(BuildContext context, dynamic sec) {
    final books = controller.booksForSection(sec.mediaLibraryId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      ).colorScheme.surfaceContainerHighest,
                    ),
                  ),
              ],
            ),
            if (sec.description != null && sec.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  sec.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            _booksGrid(context, books, sec.mediaLibraryId),
          ],
        ),
      ),
    );
  }

  Widget _booksGrid(BuildContext context, List<BookDto> books, int libraryId) {
    if (libraryId == 0) {
      return Text('未关联媒体库', style: Theme.of(context).textTheme.bodySmall);
    }
    if (controller.itemsLoading.value || controller.booksLoading.value) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (books.isEmpty) {
      return Text('暂无书籍', style: Theme.of(context).textTheme.bodySmall);
    }
    return GridView.extent(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      maxCrossAxisExtent: 180,
      childAspectRatio: 0.56,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        for (final book in books)
          BookTile(
            title: _findTag(book, 'TITLE')?.value ?? '未命名',
            author: _findTag(book, 'AUTHOR')?.value ?? '-',
            cover: _findTag(book, 'COVER')?.value,
            onTap: () => Get.toNamed('/book/${book.id}', arguments: book.id),
          ),
      ],
    );
  }

  TagDto? _findTag(BookDto book, String key) {
    for (final t in book.tags) {
      if (t.key == key) return t;
    }
    return null;
  }
}
