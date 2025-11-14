import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'recommendations_controller.dart';
import '../../services/media_libraries_service.dart';

class RecommendationsPage extends GetView<RecommendationsController> {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final libs = Get.find<MediaLibrariesService>();
    return Obx(() {
      if (controller.loading.value || libs.loading.value) {
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
        onRefresh: () async {
          await libs.loadAll();
          await controller.load();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('推荐管理 (槽位 -> 书单)', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            if (libs.error.value != null)
              Text('媒体库加载失败: ${libs.error.value}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            ...controller.slots.map((slot) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text('槽位 #${slot.id}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int?> (
                          value: slot.libraryId,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: '书单'),
                          items: [
                            const DropdownMenuItem<int?>(value: null, child: Text('未指向')),
                            ...libs.myLibraries.map(
                              (lib) => DropdownMenuItem<int?>(
                                value: lib.id,
                                child: Text(lib.name, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: controller.saving.value
                              ? null
                              : (val) => controller.updateSlotLibrary(slot.id, val),
                        ),
                      ),
                      if (controller.saving.value)
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
