import 'package:get/get.dart';
import '../../apis/client.dart';
import '../../apis/media_library_api.dart';
import '../../apis/books_api.dart';
import '../../models/media_library_models.dart';
import '../../models/book_models.dart';

class MediaLibraryDetailController extends GetxController {
  final loading = false.obs;
  final error = RxnString();
  final books = <BookTileData>[].obs; // 展示用数据（仅书籍）
  final others = <MediaLibraryItemDto>[].obs; // 子库等
  int? libraryId;
  final library = Rxn<MediaLibraryDto>(); // 改为响应式，便于标题更新

  Api get api => Get.find<Api>();

  @override
  void onInit() {
    super.onInit();
    // 路由传参 id 可能来自 Get.parameters 或 arguments
    final paramId = Get.parameters['id'];
    if (paramId != null) {
      libraryId = int.tryParse(paramId);
    } else if (Get.arguments is int) {
      libraryId = Get.arguments as int;
    } else if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['virtualMyUploaded'] == true) {
        _loadVirtualMyUploaded();
        return; // 虚拟库直接返回
      }
      if (args['id'] is int) {
        libraryId = args['id'] as int;
      }
    }
    if (libraryId != null) {
      load(libraryId!);
    } else {
      error.value = '缺少媒体库ID';
    }
  }

  Future<void> load(int id) async {
    loading.value = true;
    error.value = null;
    books.clear();
    others.clear();
    try {
      final lib = await api.getLibrary(id);
      library.value = lib;
      final items = lib.items;
      final bookIds = items
          .where((e) => e.book != null)
          .map((e) => e.book!.id)
          .toList();
      // 并发获取图书详情 -> 构建临时列表后一次性赋值，减少多次通知
      final fetched = await Future.wait(
        bookIds.map((bid) async {
          try {
            return await api.getBook(bid);
          } catch (_) {
            return null; // 忽略失败的个别图书
          }
        }),
      );
      final built = <BookTileData>[];
      for (final b in fetched.whereType<BookDto>()) {
        final tagsMap = {for (final t in b.tags) t.key.toUpperCase(): t.value};
        built.add(
          BookTileData(
            id: b.id,
            cover: tagsMap['COVER'],
            title: tagsMap['TITLE'] ?? '未命名',
            author: tagsMap['AUTHOR'] ?? '-',
          ),
        );
      }
      books.assignAll(built);
      others.assignAll(items.where((e) => e.childLibrary != null));
    } catch (e) {
      error.value = '加载失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadVirtualMyUploaded() async {
    loading.value = true;
    error.value = null;
    books.clear();
    others.clear();
    try {
      final lib = await api.getVirtualMyUploadedLibrary();
      library.value = lib;
      final items = lib.items;
      final bookIds = items
          .where((e) => e.book != null)
          .map((e) => e.book!.id)
          .toList();
      final fetched = await Future.wait(
        bookIds.map((bid) async {
          try {
            return await api.getBook(bid);
          } catch (_) {
            return null;
          }
        }),
      );
      final built = <BookTileData>[];
      for (final b in fetched.whereType<BookDto>()) {
        final tagsMap = {for (final t in b.tags) t.key.toUpperCase(): t.value};
        built.add(
          BookTileData(
            id: b.id,
            cover: tagsMap['COVER'],
            title: tagsMap['TITLE'] ?? '未命名',
            author: tagsMap['AUTHOR'] ?? '-',
          ),
        );
      }
      books.assignAll(built);
      others.assignAll(items.where((e) => e.childLibrary != null));
    } catch (e) {
      error.value = '加载虚拟库失败';
    } finally {
      loading.value = false;
    }
  }
}

class BookTileData {
  final int id;
  final String? cover; // 可能是对象key或URL
  final String title;
  final String author;
  BookTileData({
    required this.id,
    this.cover,
    required this.title,
    required this.author,
  });
}
