import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'book_detail_controller.dart';
import '../../services/media_libraries_service.dart';
import '../../widgets/side_baner.dart';

class BookDetailPage extends GetView<BookDetailController> {
  const BookDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (controller.error.value != null) {
        return Scaffold(
          appBar: AppBar(
            title: DragToMoveArea(child: const Text('图书详情')),
            flexibleSpace: DragToMoveArea(child: SizedBox.expand()),
          ),
          body: Center(
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
          ),
        );
      }
      final book = controller.book.value!;
      // 全量标签用于获取特殊标签即使它们未显示
      final allTags = book.tags;
      final tagsMapAll = {
        for (final t in allTags) t.key.toUpperCase(): t.value,
      };
      final cover = tagsMapAll['COVER'];
      final title = tagsMapAll['TITLE'] ?? '未命名';
      final author = tagsMapAll['AUTHOR'];
      final description = tagsMapAll['DESCRIPTION'];

      // 分组：仅对 shown==true 且非特殊标签进行分组展示
      final specialKeys = {'COVER', 'TITLE', 'AUTHOR', 'DESCRIPTION'};
      final grouped = <String, List<String>>{};
      for (final t in allTags) {
        if (!t.shown) continue; // 不显示的标签不进入分组区域
        final upper = t.key.toUpperCase();
        if (specialKeys.contains(upper)) continue;
        grouped.putIfAbsent(t.key, () => []).add(t.value);
      }

      return Scaffold(
        appBar: AppBar(
          title: DragToMoveArea(child: Text(title)),
          flexibleSpace: DragToMoveArea(child: SizedBox.expand()),
          actions: [
            IconButton(
              tooltip: '收藏到媒体库',
              icon: const Icon(Icons.favorite_border),
              onPressed: () async {
                final libs = Get.find<MediaLibrariesService>();
                // 若尚未加载过媒体库则主动加载一次
                if (libs.myLibraries.isEmpty && !libs.loading.value) {
                  await libs.loadAll();
                }
                if (!context.mounted) return; // async gap context safety
                if (libs.myLibraries.isEmpty) {
                  SideBanner.warning('暂无可用媒体库');
                  return;
                }
                int? selectedId = libs.myLibraries.first.id;
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('收藏到媒体库'),
                    content: DropdownButtonFormField<int>(
                      initialValue: selectedId,
                      items: libs.myLibraries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => selectedId = v,
                      decoration: const InputDecoration(labelText: '选择媒体库'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('取消'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
                if (ok == true && selectedId != null) {
                  await libs.addBookToLibrary(selectedId!, book.id);
                }
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final content = _buildContent(
              context,
              book,
              cover,
              title,
              author,
              description,
              grouped,
              wide,
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _coverBox(context, cover),
                        const SizedBox(height: 24),
                        _metaSection(book),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(flex: 7, child: content),
                ],
              );
            }
            return content; // 移动端竖向布局
          },
        ),
      );
    });
  }

  Widget _buildContent(
    BuildContext context,
    dynamic book,
    String? cover,
    String title,
    String? author,
    String? description,
    Map<String, List<String>> grouped,
    bool wide,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!wide) _coverBox(context, cover),
        if (!wide) const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (author != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              author,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.black54),
            ),
          ),
        const SizedBox(height: 12),
        _ratingSection(context),
        if (description != null && description.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('简介', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        ...grouped.entries.map((e) => _tagGroup(context, e.key, e.value)),
        const SizedBox(height: 24),
        if (!wide) _metaSection(book),
      ],
    );
  }

  Widget _coverBox(BuildContext context, String? cover) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: cover == null
            ? Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.book, size: 64, color: Colors.black45),
                ),
              )
            : Image.network(
                'http://localhost:9000/voidlord/$cover',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey.shade300),
              ),
      ),
    );
  }

  Widget _tagGroup(BuildContext context, String key, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(key, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: values.map((v) => Chip(label: Text(v))).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _metaSection(dynamic book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('元信息', style: Get.textTheme.titleSmall),
        const SizedBox(height: 8),
        _metaLine('ID', '#${book.id}'),
        if (book.createBy != null) _metaLine('上传者', '${book.createBy}'),
        if (book.createdAt != null)
          _metaLine('创建时间', book.createdAt!.toLocal().toString()),
        if (book.updatedAt != null)
          _metaLine('更新时间', book.updatedAt!.toLocal().toString()),
        const SizedBox(height: 18),
        _ratingSection(Get.context),
      ],
    );
  }

  Widget _metaLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _ratingSection(BuildContext? context) {
    if (context == null) return const SizedBox();
    return Obx(() {
      final loading = controller.ratingLoading.value;
      final my = controller.myRating.value;
      final avg = controller.avgRating.value;
      final count = controller.ratingCount.value;
      final err = controller.ratingError.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('评分', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Row(
            children: [
              for (int i = 1; i <= 5; i++) ...[
                IconButton(
                  tooltip: '评分 $i',
                  onPressed: loading ? null : () => controller.rate(i),
                  icon: Icon(
                    i <= my ? Icons.star : Icons.star_border,
                    color: i <= my
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(),
                ),
              ],
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
            Text(
              count > 0
                  ? '平均 ${avg.toStringAsFixed(1)} / 5 · 共 $count 条评分'
                  : '尚无评分，点击星星进行评分',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                err,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      );
    });
  }
}
