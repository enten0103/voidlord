import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/book_tile.dart';
// book_models.dart 未直接引用具体类型（仅通过 BookSearchController.results 访问），无需导入
import '../../widgets/side_baner.dart';
import 'book_search_controller.dart';
import '../../apis/books_api.dart';

class BookSearchPage extends GetView<BookSearchController> {
  const BookSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('图书标签条件搜索'),
          actions: [
            IconButton(
              tooltip: '重置',
              onPressed: controller.loading.value
                  ? null
                  : () {
                      controller.conditions.clear();
                      controller.results.clear();
                      controller.total.value = null;
                      controller.offset.value = 0;
                      controller.hasMore.value = false;
                    },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (ctx, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _conditionsEditor(context),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: controller.searching.value
                          ? null
                          : () async {
                              await controller.search(reset: true);
                              if (controller.results.isEmpty && controller.error.value == null) {
                                SideBanner.warning('无匹配结果');
                              }
                            },
                      icon: const Icon(Icons.search),
                      label: const Text('搜索'),
                    ),
                    const SizedBox(width: 12),
                    if (controller.loading.value)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const Spacer(),
                    // 分页大小调节
                    SizedBox(
                      width: 80,
                      child: TextField(
                        enabled: !controller.loading.value,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '每页'),
                        controller: TextEditingController(
                          text: controller.limit.value.toString(),
                        )..selection = TextSelection.fromPosition(
                            TextPosition(
                              offset: controller.limit.value.toString().length,
                            ),
                          ),
                        onSubmitted: (v) {
                          final n = int.tryParse(v.trim());
                          if (n != null && n > 0 && n <= 100) {
                            controller.limit.value = n;
                          } else {
                            SideBanner.warning('范围 1~100');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _resultsGrid(context, constraints.maxWidth),
                const SizedBox(height: 12),
                if (controller.hasMore.value)
                  Center(
                    child: FilledButton(
                      onPressed: controller.loading.value
                          ? null
                          : () => controller.loadMore(),
                      child: const Text('加载更多'),
                    ),
                  ),
                if (!controller.loading.value &&
                    controller.results.isNotEmpty &&
                    !controller.hasMore.value &&
                    controller.total.value != null)
                  Center(
                    child: Text(
                      '已全部加载 (${controller.results.length}/${controller.total.value})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (controller.error.value != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      controller.error.value!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _conditionsEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('条件 (AND)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: controller.loading.value
                  ? null
                  : () => controller.addCondition(),
              icon: const Icon(Icons.add),
              label: const Text('添加条件'),
            ),
            const Spacer(),
            if (controller.conditions.isNotEmpty)
              TextButton(
                onPressed: controller.loading.value
                    ? null
                    : () => controller.conditions.clear(),
                child: const Text('清空'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (controller.conditions.isEmpty)
          Text(
            '未添加条件：后端会返回全部书籍（可能很多），建议至少添加一个。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        for (int i = 0; i < controller.conditions.length; i++)
          _conditionRow(context, i, controller.conditions[i]),
      ],
    );
  }

  Widget _conditionRow(BuildContext context, int index, BookSearchCondition c) {
    final ops = ['eq', 'neq', 'match'];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: TextField(
                decoration: const InputDecoration(labelText: '标签 Key'),
                controller: TextEditingController(text: c.target)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: c.target.length),
                  ),
                onChanged: (v) => controller.updateCondition(index, target: v.trim()),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: c.op,
              items: ops
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.updateCondition(index, op: v);
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: '值'),
                controller: TextEditingController(text: c.value)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: c.value.length),
                  ),
                onChanged: (v) => controller.updateCondition(index, value: v),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: '删除',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => controller.removeCondition(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultsGrid(BuildContext context, double maxWidth) {
    if (controller.results.isEmpty) {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return const SizedBox();
    }
    final columns = _computeColumns(maxWidth);
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.results.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (ctx, i) {
        final b = controller.results[i];
        // 提取标题与作者标签（若不存在则回退为空字符串）
        String title = '';
        String author = '';
        for (final t in b.tags) {
          if (t.key == 'title') title = t.value;
          if (t.key == 'author') author = t.value;
        }
        return BookTile(title: title, author: author);
      },
    );
  }

  int _computeColumns(double maxWidth) {
    if (maxWidth < 520) return 2;
    if (maxWidth < 720) return 3;
    if (maxWidth < 1024) return 4;
    return 5;
  }
}