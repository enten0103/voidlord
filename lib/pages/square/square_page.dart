import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              sliver: _lazySectionsSliver(context),
            ),
          ],
        ),
      );
    });
  }

  /// 懒加载分区：使用 SliverChildBuilderDelegate，仅构建可见 header 和其书籍网格
  SliverMultiBoxAdaptorWidget _lazySectionsSliver(BuildContext context) {
    final secs = controller.sections;
    if (secs.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Text('暂无推荐分区', style: Theme.of(context).textTheme.bodySmall),
        ]),
      );
    }
    final itemCount = secs.length * 2; // header + grid per section
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, index) {
        final secIndex = index ~/ 2;
        final isHeader = index % 2 == 0;
        final sec = secs[secIndex];
        if (isHeader) {
          // 触发库初始化（只在 header 首次构建时）
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.ensureLibraryInitialized(sec.mediaLibraryId);
          });
          return _sectionHeader(context, sec);
        } else {
          // 使用 Obx 包裹书籍区域以响应 libraryLoading/HasMore 等变化
          return Obx(() => _sectionBooksSliverWrapper(context, sec));
        }
      }, childCount: itemCount),
    );
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

  Widget _sectionBooksSliverWrapper(BuildContext context, dynamic sec) {
    final libId = sec.mediaLibraryId;
    if (libId == 0) {
      return Text('未关联媒体库', style: Theme.of(context).textTheme.bodySmall);
    }
    final books = controller.booksForSection(libId);
    final loading = controller.libraryLoading[libId] == true && books.isEmpty;
    if (loading) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (books.isEmpty) {
      return Text('暂无书籍', style: Theme.of(context).textTheme.bodySmall);
    }
    final hasMore = controller.libraryHasMore[libId] == true;
    final loadingMore =
        controller.libraryLoading[libId] == true && books.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveBookGrid(
          books: books,
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          onTap: (b) => Get.toNamed(Routes.bookDetail, arguments: b.id),
        ),
        if (hasMore)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: loadingMore
                  ? const SizedBox(
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => controller.loadMoreLibrary(libId),
                      icon: const Icon(Icons.more_horiz),
                      label: const Text('加载更多'),
                    ),
            ),
          ),
      ],
    );
  }
}
