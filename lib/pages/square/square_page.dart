import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../root/square_controller.dart';
import '../../routes/app_routes.dart';

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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                              ),
                            ),
                          IconButton(
                            tooltip: '打开媒体库',
                            icon: const Icon(Icons.open_in_new),
                            onPressed: sec.mediaLibraryId == 0
                                ? null
                                : () => Get.toNamed(
                                      '${Routes.mediaLibraryDetail}/${sec.mediaLibraryId}',
                                      arguments: sec.mediaLibraryId,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sec.mediaLibraryName ?? '未关联媒体库',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (sec.description != null && sec.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            sec.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 8),
                      _itemsSection(context, sec.mediaLibraryId),
                    ],
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

  Widget _itemsSection(BuildContext context, int libraryId) {
    final items = controller.itemsFor(libraryId);
    if (libraryId == 0) {
      return Text('未关联媒体库', style: Theme.of(context).textTheme.bodySmall);
    }
    if (controller.itemsLoading.value) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (items.isEmpty) {
      return Text('暂无条目', style: Theme.of(context).textTheme.bodySmall);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('条目(${items.length})', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((it) {
            if (it.book != null) {
              final book = controller.bookFor(it.book!.id);
              final titleTag = book?.tags.firstWhereOrNull((t) => t.key == 'TITLE');
              final authorTag = book?.tags.firstWhereOrNull((t) => t.key == 'AUTHOR');
              final display = [
                if (titleTag != null) titleTag.value,
                if (authorTag != null) authorTag.value,
                'ID:${it.book!.id}',
              ].join(' / ');
              return _bookChip(context, display, it.book!.id);
            }
            if (it.childLibrary != null) {
              return Chip(
                label: Text('子库#${it.childLibrary!.id}'),
                visualDensity: VisualDensity.compact,
              );
            }
            return Chip(
              label: Text('条目#${it.id}'),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _bookChip(BuildContext context, String text, int bookId) {
    return ActionChip(
      label: Text(text, overflow: TextOverflow.ellipsis),
      visualDensity: VisualDensity.compact,
      onPressed: () => Get.toNamed('/book/$bookId', arguments: bookId),
    );
  }
}
