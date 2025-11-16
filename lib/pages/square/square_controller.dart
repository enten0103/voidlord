import 'package:get/get.dart';
import 'package:voidlord/apis/client.dart';
import 'package:voidlord/apis/recommendations_api.dart';
import 'package:voidlord/models/recommendations_models.dart';
import 'package:voidlord/services/media_libraries_service.dart';
import 'package:voidlord/apis/media_library_api.dart';
import 'package:voidlord/apis/books_api.dart';
import 'package:voidlord/models/book_models.dart';

class SquareController extends GetxController {
  final loading = false.obs;
  final error = RxnString();
  final sections = <RecommendationSectionDto>[].obs;
  // 懒加载相关状态
  final bookCache = <int, BookDto>{}.obs; // 全局书籍缓存 bookId -> BookDto
  final libraryBookIds = <int, List<int>>{}.obs; // libraryId -> 已加载的书籍ID顺序
  final libraryOffsets = <int, int>{}.obs; // libraryId -> 当前偏移量
  final libraryLoading = <int, bool>{}.obs; // libraryId -> 是否正在加载
  final libraryHasMore = <int, bool>{}.obs; // libraryId -> 是否还有更多
  final libraryTotal = <int, int>{}.obs; // libraryId -> itemsCount 总数
  final initializedLibraries = <int>{}.obs; // 已初始化的库ID
  final pageSize = 20; // 单次分页大小

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
      // 预加载前两个分区以提升首屏感知
      final preload = sections.take(2).map((e) => e.mediaLibraryId);
      for (final id in preload) {
        await ensureLibraryInitialized(id);
      }
    } catch (e) {
      error.value = '加载推荐分区失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> ensureLibraryInitialized(int libraryId) async {
    if (libraryId <= 0) return; // 0 代表未关联
    if (initializedLibraries.contains(libraryId)) return;
    await _fetchLibrarySegment(libraryId, reset: true);
    initializedLibraries.add(libraryId);
  }

  Future<void> loadMoreLibrary(int libraryId) async {
    if (libraryId <= 0) return;
    if (libraryLoading[libraryId] == true) return;
    if (libraryHasMore[libraryId] != true) return;
    await _fetchLibrarySegment(libraryId, reset: false);
  }

  Future<void> _fetchLibrarySegment(
    int libraryId, {
    required bool reset,
  }) async {
    libraryLoading[libraryId] = true;
    final currentOffset = reset ? 0 : (libraryOffsets[libraryId] ?? 0);
    try {
      final lib = await api.getLibrary(
        libraryId,
        limit: pageSize,
        offset: currentOffset,
      );
      libraryTotal[libraryId] = lib.itemsCount;
      // 收集书籍ID
      final ids = <int>[];
      for (final item in lib.items) {
        if (item.book != null) ids.add(item.book!.id);
      }
      // 拉取缺失书籍详情
      final need = ids.where((id) => !bookCache.containsKey(id)).toList();
      if (need.isNotEmpty) {
        final futures = need.map((id) => api.getBook(id));
        final results = await Future.wait(futures);
        for (final b in results) {
          bookCache[b.id] = b;
        }
      }
      if (reset) {
        libraryBookIds[libraryId] = ids;
      } else {
        final list = libraryBookIds[libraryId] ?? <int>[];
        list.addAll(ids);
        libraryBookIds[libraryId] = list;
      }
      final newOffset = currentOffset + ids.length;
      libraryOffsets[libraryId] = newOffset;
      libraryHasMore[libraryId] = newOffset < (lib.itemsCount);
    } catch (_) {
      // 错误暂时静默，保留已加载部分
    } finally {
      libraryLoading[libraryId] = false;
    }
  }

  BookDto? bookFor(int id) => bookCache[id];

  List<BookDto> booksForSection(int libraryId) {
    final ids = libraryBookIds[libraryId] ?? const [];
    return ids.map((e) => bookCache[e]).whereType<BookDto>().toList();
  }
}
