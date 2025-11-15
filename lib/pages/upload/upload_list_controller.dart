import 'package:get/get.dart';
import '../../apis/client.dart';
import '../../apis/books_api.dart';
import '../../apis/media_library_api.dart';
import '../../models/book_models.dart';
import '../../models/media_library_models.dart';

class UploadListController extends GetxController {
  final loading = false.obs;
  final error = RxnString();
  final books = <BookDto>[].obs;
  final limit = 20.obs;
  final offset = 0.obs;
  final loadingMore = false.obs;
  final noMore = false.obs;
  final totalCount = 0.obs;

  Api get api => Get.find<Api>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    books.clear();
    offset.value = 0;
    noMore.value = false;
    try {
      final lib = await api.getVirtualMyUploadedLibrary(
        limit: limit.value,
        offset: 0,
      );
      totalCount.value = lib.itemsCount;
      await _appendItems(lib.items);
      _updateNoMore();
    } catch (e) {
      error.value = '加载失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (loadingMore.value || noMore.value) return;
    loadingMore.value = true;
    try {
      final nextOffset = books.length;
      final lib = await api.getVirtualMyUploadedLibrary(
        limit: limit.value,
        offset: nextOffset,
      );
      await _appendItems(lib.items);
      offset.value = nextOffset;
      _updateNoMore(total: lib.itemsCount);
    } catch (_) {
      // ignore
    } finally {
      loadingMore.value = false;
    }
  }

  Future<void> _appendItems(List<MediaLibraryItemDto> items) async {
    final bookIds = items
        .where((e) => e.book != null)
        .map((e) => e.book!.id)
        .toList();
    if (bookIds.isEmpty) return;
    final fetched = await Future.wait(
      bookIds.map((bid) async {
        try {
          return await api.getBook(bid);
        } catch (_) {
          return null;
        }
      }),
    );
    books.addAll(fetched.whereType<BookDto>());
  }

  void _updateNoMore({int? total}) {
    final t = total ?? totalCount.value;
    if (books.length >= t) noMore.value = true;
  }
}
