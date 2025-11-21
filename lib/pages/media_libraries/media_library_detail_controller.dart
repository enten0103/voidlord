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

  // 搜索模式状态
  final isSearchMode = false.obs;
  final searchConditions = <BookSearchCondition>[];

  // 分页状态
  final limit = 20.obs;
  final offset = 0.obs;
  final loadingMore = false.obs;
  final noMore = false.obs;

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
      if (args['searchConditions'] != null) {
        isSearchMode.value = true;
        searchConditions.addAll(
          (args['searchConditions'] as List).cast<BookSearchCondition>(),
        );
        load(0); // 搜索模式下 ID 无意义，传 0
        return;
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
    // 初次加载或刷新重置分页
    loading.value = true;
    error.value = null;
    books.clear();
    others.clear();
    offset.value = 0;
    noMore.value = false;
    try {
      if (isSearchMode.value) {
        final resp = await api.searchBooks(
          conditions: searchConditions,
          limit: limit.value,
          offset: 0,
        );
        _appendBookDtos(resp.items);
        _updateNoMore(total: resp.total);
      } else {
        final lib = await api.getLibrary(id, limit: limit.value, offset: 0);
        library.value = lib;
        await _appendItems(lib.items);
        _updateNoMore();
      }
    } catch (e) {
      error.value = '加载失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (loadingMore.value || noMore.value) return;
    if (!isSearchMode.value && libraryId == null) return;
    loadingMore.value = true;
    try {
      final nextOffset = books.length + others.length; // 仅书籍影响分页，此处简化
      if (isSearchMode.value) {
        final resp = await api.searchBooks(
          conditions: searchConditions,
          limit: limit.value,
          offset: nextOffset,
        );
        _appendBookDtos(resp.items);
        _updateNoMore(total: resp.total);
      } else {
        final lib = await api.getLibrary(
          libraryId!,
          limit: limit.value,
          offset: nextOffset,
        );
        await _appendItems(lib.items);
        _updateNoMore(total: lib.itemsCount);
      }
      offset.value = nextOffset;
    } catch (_) {
      // 忽略加载更多失败
    } finally {
      loadingMore.value = false;
    }
  }

  void _appendBookDtos(List<BookDto> items) {
    final built = <BookTileData>[];
    for (final b in items) {
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
    books.addAll(built);
  }

  Future<void> _appendItems(List<MediaLibraryItemDto> items) async {
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
    books.addAll(built);
    others.addAll(items.where((e) => e.childLibrary != null));
  }

  void _updateNoMore({int? total}) {
    final totalCount = total ?? library.value?.itemsCount ?? 0;
    if (books.length >= totalCount) {
      noMore.value = true;
    }
  }

  Future<void> _loadVirtualMyUploaded() async {
    loading.value = true;
    error.value = null;
    books.clear();
    others.clear();
    offset.value = 0;
    noMore.value = false;
    try {
      final lib = await api.getVirtualMyUploadedLibrary(
        limit: limit.value,
        offset: 0,
      );
      library.value = lib;
      await _appendItems(lib.items);
      _updateNoMore(total: lib.itemsCount);
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
