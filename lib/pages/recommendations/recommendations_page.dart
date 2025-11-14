import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'recommendations_controller.dart';

class RecommendationsPage extends GetView<RecommendationsController> {
  const RecommendationsPage({super.key});

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
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('推荐管理', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '书籍ID',
                      hintText: '输入书籍ID添加到推荐',
                    ),
                    onSubmitted: (v) {
                      final id = int.tryParse(v.trim());
                      if (id != null) controller.addBook(id);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: controller.load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('刷新'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: controller.recommendedBooks.isEmpty
                  ? const Center(child: Text('暂无推荐'))
                  : ListView.builder(
                      itemCount: controller.recommendedBooks.length,
                      itemBuilder: (context, i) {
                        final id = controller.recommendedBooks[i];
                        return ListTile(
                          leading: const Icon(Icons.bookmark_add_outlined),
                          title: Text('书籍 #$id'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => controller.removeBook(id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}
