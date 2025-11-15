import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/models/book_models.dart';
import '../../widgets/adaptive_book_grid.dart';
import '../../routes/app_routes.dart';
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
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              sliver: _mixedSectionsSliver(context),
            ),
          ],
        ),
      );
    });
  }

  /// 构建“推荐标题全宽 + 普通书籍网格”混合展示的自定义 Sliver
  SliverMultiBoxAdaptorWidget _mixedSectionsSliver(BuildContext context) {
    final secs = controller.sections;
    if (secs.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Text('暂无推荐分区', style: Theme.of(context).textTheme.bodySmall),
        ]),
      );
    }

    // 将每个分区拆分为：Header(全宽) + Books(网格)
    final children = <Widget>[];
    for (final sec in secs) {
      children.add(_sectionHeader(context, sec));
      final books = controller.booksForSection(sec.mediaLibraryId);
      children.add(_sectionBooksSliverWrapper(context, sec, books));
    }
    return SliverList(delegate: SliverChildListDelegate(children));
  }

  Widget _sectionHeader(BuildContext context, dynamic sec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
                  ),
                ),
            ],
          ),
          if (sec.description != null && sec.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                sec.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionBooksSliverWrapper(
    BuildContext context,
    dynamic sec,
    List<BookDto> books,
  ) {
    if (controller.itemsLoading.value || controller.booksLoading.value) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (sec.mediaLibraryId == 0) {
      return Text('未关联媒体库', style: Theme.of(context).textTheme.bodySmall);
    }
    if (books.isEmpty) {
      return Text('暂无书籍', style: Theme.of(context).textTheme.bodySmall);
    }
    // 网格用自适应组件；这里在 SliverList 的 item 中嵌套一个不可滚动 GridView
    return AdaptiveBookGrid(
      books: books,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      onTap: (b) => Get.toNamed(Routes.bookDetail, arguments: b.id),
    );
  }
}
