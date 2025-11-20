import 'dart:async';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voidlord/widgets/side_baner.dart';

/// 管理前端图片质量与缓存大小的服务。
/// 提供以下可调参数：
/// 1. filterQuality (对解码与缩放的质量提示)
/// 2. scaleFactor (根据组件尺寸计算请求/缓存的像素宽度缩放系数)
/// 3. compressionQuality (未来用于后端 query，如 ?q=80；暂预留)
/// 4. maxMemoryCacheMb (内存缓存大小限制)
/// 并可实时统计当前磁盘缓存占用（MB）。

class ImageCacheSettingsService extends GetxService {
  static const _prefQualityKey = 'img_quality_percent';
  static const _prefMaxMemoryCacheKey = 'img_max_memory_cache_mb';
  static const _cacheKey = 'voidlord_img_cache';

  final qualityPercent = 80.obs; // 10-100
  final maxMemoryCacheMb = 100.obs; // 默认 100MB 内存缓存
  final diskCacheMb = 0.0.obs;
  final measuring = false.obs;

  late final CacheManager cacheManager;

  /// 初始化：读取偏好并计算当前缓存大小。
  Future<ImageCacheSettingsService> init() async {
    cacheManager = CacheManager(
      Config(
        _cacheKey,
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 5000,
        repo: JsonCacheInfoRepository(databaseName: _cacheKey),
        fileService: HttpFileService(),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    qualityPercent.value =
        prefs.getInt(_prefQualityKey) ?? qualityPercent.value;
    maxMemoryCacheMb.value =
        prefs.getInt(_prefMaxMemoryCacheKey) ?? maxMemoryCacheMb.value;
    _applyMemoryCacheLimit();
    unawaited(refreshDiskCacheSize());
    return this;
  }

  void _applyMemoryCacheLimit() {
    // maximumSizeBytes is in bytes
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        maxMemoryCacheMb.value * 1024 * 1024;
  }

  Future<void> setQualityPercent(int v) async {
    qualityPercent.value = v.clamp(10, 100);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefQualityKey, qualityPercent.value);
  }

  Future<void> setMaxMemoryCacheMb(int mb) async {
    maxMemoryCacheMb.value = mb.clamp(50, 500); // 限制在 50MB - 500MB
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefMaxMemoryCacheKey, maxMemoryCacheMb.value);
    _applyMemoryCacheLimit();
  }

  /// 估算默认缓存目录大小。
  Future<void> refreshDiskCacheSize() async {
    if (measuring.value) return;
    measuring.value = true;
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory(p.join(tempDir.path, _cacheKey));
      if (!cacheDir.existsSync()) {
        diskCacheMb.value = 0;
      } else {
        final bytes = await _dirSize(cacheDir);
        diskCacheMb.value = bytes / (1024 * 1024);
      }
    } catch (e) {
      // 忽略异常
    } finally {
      measuring.value = false;
    }
  }

  Future<int> _dirSize(Directory dir) async {
    int total = 0;
    if (!await dir.exists()) return 0;
    try {
      final files = dir.list(recursive: true, followLinks: false);
      await for (final entity in files) {
        if (entity is File) {
          final length = await entity.length();
          total += length;
        }
      }
    } catch (e) {
      // ignore
    }
    return total;
  }

  /// 清空全部磁盘缓存。
  Future<void> clearDiskCache() async {
    // 1. 清理 CacheManager 记录
    await cacheManager.emptyCache();

    // 2. 强制清理内存中的图片缓存
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // 3. 强制物理删除缓存目录（解决 CacheManager 可能残留孤儿文件的问题）
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory(p.join(tempDir.path, _cacheKey));
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      SideBanner.danger('Delete cache dir failed: $e');
    }

    // 4. 刷新统计
    await refreshDiskCacheSize();
  }
}
