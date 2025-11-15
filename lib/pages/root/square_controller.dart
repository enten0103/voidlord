import 'package:get/get.dart';
import 'package:voidlord/apis/client.dart';
import 'package:voidlord/apis/recommendations_api.dart';
import 'package:voidlord/models/recommendations_models.dart';
import 'package:voidlord/services/media_libraries_service.dart';
import 'package:voidlord/models/media_library_models.dart';
import 'package:voidlord/apis/media_library_api.dart';
import 'package:voidlord/apis/books_api.dart';
import 'package:voidlord/models/book_models.dart';

class SquareController extends GetxController {
  final loading = false.obs;
  final error = RxnString();
  final sections = <RecommendationSectionDto>[].obs;
  final libraries = <int, MediaLibraryDto>{}.obs; // libraryId -> full dto
  final itemsLoading = false.obs; // 条目批量加载中
  final booksLoading = false.obs; // 书籍详情批量加载中
  final bookCache = <int, BookDto>{}.obs; // bookId -> BookDto

  Api get api => Get.find<Api>();
  MediaLibrariesService get libs => Get.find<MediaLibrariesService>();

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await libs.ensureInitialized();
    await load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final list = await api.listSections(all: true);
      final nameMap = {
        if (libs.readingRecord.value != null)
          libs.readingRecord.value!.id: libs.readingRecord.value!.name,
        for (final m in libs.myLibraries) m.id: m.name,
      };
      sections.assignAll(
        list.map(
          (s) => RecommendationSectionDto(
            id: s.id,
            key: s.key,
            title: s.title,
            description: s.description,
            active: s.active,
            sortOrder: s.sortOrder,
            mediaLibraryId: s.mediaLibraryId,
            mediaLibraryName: nameMap[s.mediaLibraryId] ?? s.mediaLibraryName,
          ),
        ),
      );
      sections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      await _loadLibraryDetails();
    } catch (e) {
      error.value = '加载推荐分区失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadLibraryDetails() async {
    final ids = sections
        .map((e) => e.mediaLibraryId)
        .where((id) => id > 0)
        .toSet();
    final need = ids.where((id) => !libraries.containsKey(id)).toList();
    if (need.isEmpty) {
      // 已有库也补充书籍（避免首次加载后条目变更时书籍缺失）
      await _loadBooksFromLibraries(libraries.values.toList());
      return;
    }
    itemsLoading.value = true;
    try {
      final futures = need.map((id) => api.getLibrary(id));
      final results = await Future.wait(futures);
      for (final lib in results) {
        libraries[lib.id] = lib;
      }
      await _loadBooksFromLibraries(results);
    } catch (_) {
      // 忽略局部失败，保留已加载内容
    } finally {
      itemsLoading.value = false;
    }
  }

  Future<void> _loadBooksFromLibraries(List<MediaLibraryDto> libsList) async {
    final bookIds = <int>{};
    for (final lib in libsList) {
      for (final item in lib.items) {
        if (item.book != null) bookIds.add(item.book!.id);
      }
    }
    final need = bookIds.where((id) => !bookCache.containsKey(id)).toList();
    if (need.isEmpty) return;
    booksLoading.value = true;
    try {
      final futures = need.map((id) => api.getBook(id));
      final results = await Future.wait(futures);
      for (final b in results) {
        bookCache[b.id] = b;
      }
    } catch (_) {
      // 忽略部分失败
    } finally {
      booksLoading.value = false;
    }
  }

  List<MediaLibraryItemDto> itemsFor(int libraryId) {
    final lib = libraries[libraryId];
    return lib?.items ?? const [];
  }

  BookDto? bookFor(int id) => bookCache[id];
}
