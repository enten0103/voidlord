import 'dart:async';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 管理前端图片质量与缓存大小的服务。
/// 提供以下可调参数：
/// 1. filterQuality (对解码与缩放的质量提示)
/// 2. scaleFactor (根据组件尺寸计算请求/缓存的像素宽度缩放系数)
/// 3. compressionQuality (未来用于后端 query，如 ?q=80；暂预留)
/// 4. maxCacheMb (超过后触发修剪)
/// 并可实时统计当前缓存占用（MB）。

class ImageCacheSettingsService extends GetxService {
  static const _prefQualityKey = 'img_quality_percent';
  static const _prefMaxCacheKey = 'img_max_cache_mb';

  final qualityPercent = 80.obs; // 10-100
  final maxCacheMb = 200.obs; // 默认 200MB 上限
  final currentCacheMb = 0.0.obs;
  final measuring = false.obs;

  /// 初始化：读取偏好并计算当前缓存大小。
  Future<ImageCacheSettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    qualityPercent.value =
        prefs.getInt(_prefQualityKey) ?? qualityPercent.value;
    maxCacheMb.value = prefs.getInt(_prefMaxCacheKey) ?? maxCacheMb.value;
    unawaited(refreshCurrentCacheSize());
    return this;
  }

  Future<void> setQualityPercent(int v) async {
    qualityPercent.value = v.clamp(10, 100);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefQualityKey, qualityPercent.value);
  }

  Future<void> setMaxCacheMb(int mb) async {
    maxCacheMb.value = mb.clamp(50, 2000); // 限制在 50MB - 2GB
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefMaxCacheKey, maxCacheMb.value);
    unawaited(applyTrimmingIfNeeded());
  }

  /// 估算默认缓存目录大小。cached_network_image 使用 DefaultCacheManager。
  Future<void> refreshCurrentCacheSize() async {
    if (measuring.value) return;
    measuring.value = true;
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/libCachedImageData');
      if (!cacheDir.existsSync()) {
        currentCacheMb.value = 0;
      } else {
        final bytes = await _dirSize(cacheDir);
        currentCacheMb.value = bytes / (1024 * 1024);
      }
    } catch (e) {
      // 忽略异常
    } finally {
      measuring.value = false;
      unawaited(applyTrimmingIfNeeded());
    }
  }

  Future<int> _dirSize(Directory dir) async {
    int total = 0;
    final files = dir.list(recursive: true, followLinks: false);
    await for (final entity in files) {
      if (entity is File) {
        final length = await entity.length();
        total += length;
      }
    }
    return total;
  }

  /// 如果超出限制，按最旧文件优先删除直到降到上限 90% 以下。
  Future<void> applyTrimmingIfNeeded() async {
    if (currentCacheMb.value <= maxCacheMb.value) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/libCachedImageData');
      if (!cacheDir.existsSync()) return;
      final files = <File>[];
      final stream = cacheDir.list(recursive: true, followLinks: false);
      await for (final e in stream) {
        if (e is File) files.add(e);
      }
      files.sort(
        (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
      ); // 旧的在前
      double target = maxCacheMb.value * 0.9; // 修剪到 90%
      double current = currentCacheMb.value;
      for (final f in files) {
        if (current <= target) break;
        final len = await f.length();
        try {
          await f.delete();
        } catch (_) {}
        current -= len / (1024 * 1024);
      }
      currentCacheMb.value = current;
    } catch (_) {
      // 忽略
    }
  }

  /// 清空全部缓存。
  Future<void> clearAllCache() async {
    await DefaultCacheManager().emptyCache();
    await refreshCurrentCacheSize();
  }
}
