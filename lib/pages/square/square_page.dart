import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/models/book_models.dart';
import '../root/square_controller.dart';

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
              FilledButton(
                onPressed: controller.load,
                child: const Text('重试'),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async => controller.load(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final sec in controller.sections)
              _sectionCard(context, sec),
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
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
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
    // 与媒体库详情页面一致的竖向封面网格风格
    return GridView.extent(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      maxCrossAxisExtent: 180,
      childAspectRatio: 0.56,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        for (final book in books)
          InkWell(
            onTap: () => Get.toNamed('/book/${book.id}', arguments: book.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _buildCover(_findTag(book, 'COVER')?.value),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _findTag(book, 'TITLE')?.value ?? '未命名',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _findTag(book, 'AUTHOR')?.value ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
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
