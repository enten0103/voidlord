import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/services/config_service.dart';
import '../services/image_cache_settings_service.dart';

/// 通用书籍展示组件：封面 + 标题 + 作者。
class BookTile extends StatelessWidget {
  final String title;
  final String author;
  final String? cover; // URL 或对象 key
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double radius;

  const BookTile({
    super.key,
    required this.title,
    required this.author,
    this.cover,
    this.onTap,
    this.onLongPress,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        onLongPress: onLongPress,
        splashFactory: InkRipple.splashFactory,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: 8,
            end: 8,
            top: 8,
            bottom: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(radius - 2),
                      child: _buildCover(constraints.maxWidth),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title.isEmpty ? '未命名' : title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                author.isEmpty ? '-' : author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(double logicalWidth) {
    if (cover == null || cover!.trim().isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.book, size: 32, color: Colors.black45),
        ),
      );
    }
    final src = '${Get.find<ConfigService>().minioUrl}/voidlord/$cover';
    final svc = Get.isRegistered<ImageCacheSettingsService>()
        ? Get.find<ImageCacheSettingsService>()
        : null;
    if (svc == null) {
      return CachedNetworkImage(
        imageUrl: src,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Container(color: Colors.grey.shade300),
      );
    }
    return Obx(() {
      final percent = svc.qualityPercent.value;
      final dpr = MediaQuery.of(Get.context!).devicePixelRatio;
      // 以百分比线性缩放目标像素宽度，最低 80，最高 2000
      final targetWidth = (logicalWidth * dpr * percent / 100)
          .clamp(80, 2000)
          .toInt();
      return CachedNetworkImage(
        imageUrl: src,
        fit: BoxFit.cover,
        memCacheWidth: targetWidth,
        cacheManager: svc.cacheManager,
        errorWidget: (_, __, ___) => Container(color: Colors.grey.shade300),
      );
    });
  }
}
