import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:voidlord/routes/app_routes.dart';
import 'package:voidlord/services/config_service.dart';
import 'package:voidlord/widgets/download_dialog.dart';
import 'package:voidlord/widgets/parse_book_dialog.dart';
import '../../apis/client.dart';
import '../../apis/books_api.dart';
import '../../models/book_models.dart';
import '../../widgets/side_baner.dart';
import '../../services/media_libraries_service.dart';

class BookDetailController extends GetxController {
  final loading = false.obs;
  final deleting = false.obs;
  final error = RxnString();
  final book = Rxn<BookDto>();
  // Rating state
  final ratingLoading = false.obs;
  final ratingError = RxnString();
  final myRating = 0.obs;
  final avgRating = 0.0.obs;
  final ratingCount = 0.obs;

  Api get api => Get.find<Api>();

  int? bookId;

  @override
  void onInit() {
    super.onInit();
    try {
      final libs = Get.find<MediaLibrariesService>();
      libs.ensureInitialized();
    } catch (_) {}
    int? id;
    final paramId = Get.parameters['id'];
    if (paramId != null) id = int.tryParse(paramId);
    if (id == null && Get.arguments is int) id = Get.arguments as int;
    if (id == null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['id'] is int) id = args['id'] as int;
    }
    bookId = id;
    if (bookId != null) {
      load();
    } else {
      error.value = '未提供图书 ID';
    }
  }

  Future<void> load() async {
    if (bookId == null) return;
    loading.value = true;
    error.value = null;
    try {
      final data = await api.getBook(bookId!);
      book.value = data;
      await loadRating();
    } catch (e) {
      error.value = '加载失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadRating() async {
    if (bookId == null) return;
    ratingLoading.value = true;
    ratingError.value = null;
    try {
      final r = await api.getBookRating(bookId!);
      if (r != null) {
        myRating.value = r.myRating;
        avgRating.value = r.avg;
        ratingCount.value = r.count;
      }
    } catch (e) {
      ratingError.value = '评分加载失败';
    } finally {
      ratingLoading.value = false;
    }
  }

  Future<void> rate(int score) async {
    if (bookId == null) return;
    if (score < 1 || score > 5) return;
    ratingLoading.value = true;
    try {
      final r = await api.rateBook(bookId!, score);
      myRating.value = r.myRating;
      avgRating.value = r.avg;
      ratingCount.value = r.count;
      SideBanner.info('评分成功: ${r.myRating}');
    } catch (e) {
      if (e is BooksApiError && e.statusCode == 401) {
        SideBanner.warning('请先登录后评分');
      } else if (e is BooksApiError) {
        SideBanner.danger(e.message);
      } else {
        SideBanner.danger('评分失败');
      }
    } finally {
      ratingLoading.value = false;
    }
  }

  Future<void> deleteCurrent() async {
    if (bookId == null) return;
    deleting.value = true;
    try {
      final ok = await api.deleteBook(bookId!);
      if (ok) {
        SideBanner.info('已删除图书 #$bookId');
        Get.back(result: true);
      } else {
        SideBanner.danger('删除失败');
      }
    } catch (e) {
      SideBanner.danger('删除异常');
    } finally {
      deleting.value = false;
    }
  }

  // 下载 → 解析并保存 → 导航阅读器
  Future<void> read() async {
    try {
      final key = book.value!.tags.firstWhereOrNull(
        (tag) => tag.key == "SOURCE",
      );
      if (key == null || key.value.isEmpty) {
        SideBanner.danger('无法获取书籍下载地址');
        return;
      }

      final hash = key.value;
      final minioUrl = Get.find<ConfigService>().config.minioUrl;
      final url = '$minioUrl/voidlord/${key.value}';
      final tmpDir = await getTemporaryDirectory();
      final savePath = p.join(tmpDir.path, '$hash.epub');
      // 0. 若本地已存在解析结果则直接打开
      final docDir = await getApplicationDocumentsDirectory();
      final tonoJson = File(p.join(docDir.path, 'book', hash, 'tono.json'));
      if (await tonoJson.exists()) {
        await Get.toNamed(
          Routes.readerPage,
          parameters: {'hash': hash, 'type': 'local'},
        );
        return;
      }

      // 1. 显示下载进度弹窗
      final ok = await Get.dialog<bool>(
        DownloadDialog(url: url, savePath: savePath),
        barrierDismissible: false,
        barrierColor: Colors.black45,
      );
      if (ok != true) {
        throw Exception('下载失败');
      }

      await Get.dialog(
        ParseBookDialog(filePath: savePath, returnTono: false),
        barrierDismissible: false,
        barrierColor: Colors.black45,
      );

      await Get.toNamed(
        Routes.readerPage,
        parameters: {'hash': hash, 'type': 'local'},
      );
    } catch (e) {
      Get.snackbar('读取失败', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
