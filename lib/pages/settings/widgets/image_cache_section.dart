import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/image_cache_settings_service.dart';

class ImageCacheSection extends StatelessWidget {
  const ImageCacheSection({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<ImageCacheSettingsService>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('图片与缓存', style: Get.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('图片质量（百分比，数值越高越清晰）：', style: Get.textTheme.bodyMedium),
            Obx(
              () => Slider(
                value: svc.qualityPercent.value.toDouble(),
                min: 10,
                max: 100,
                divisions: 18,
                label: '${svc.qualityPercent.value}%',
                onChanged: (v) => svc.setQualityPercent(v.round()),
              ),
            ),
            const SizedBox(height: 20),
            Text('内存缓存限制 (重启生效)：', style: Get.textTheme.bodyMedium),
            Obx(
              () => Slider(
                value: svc.maxMemoryCacheMb.value.toDouble(),
                min: 50,
                max: 500,
                divisions: 9,
                label: '${svc.maxMemoryCacheMb.value}MB',
                onChanged: (v) => svc.setMaxMemoryCacheMb(v.round()),
              ),
            ),
            const SizedBox(height: 20),
            Text('磁盘缓存占用：', style: Get.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Obx(() {
              final current = svc.diskCacheMb.value;
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      '当前 ${current.toStringAsFixed(1)} MB',
                      style: Get.textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    tooltip: '刷新',
                    onPressed: () => svc.refreshDiskCacheSize(),
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    tooltip: '清空磁盘缓存',
                    onPressed: () async {
                      await svc.clearDiskCache();
                      Get.snackbar('缓存', '已清空磁盘缓存');
                    },
                    icon: const Icon(Icons.delete_sweep),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
