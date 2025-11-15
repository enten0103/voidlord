import 'package:get/get.dart';
import '../apis/client.dart';
import '../apis/media_library_api.dart';
import '../models/media_library_models.dart';
import '../widgets/side_baner.dart';

class MediaLibrariesService extends GetxService {
  final readingRecord = Rxn<MediaLibraryDto>();
  final virtualMyUploaded = Rxn<MediaLibraryDto>();
  final myLibraries = <MediaLibraryDto>[].obs;
  final loading = false.obs;
  final error = RxnString();
  bool _initialized = false; // 是否已执行过初始化加载

  Api get api => Get.find<Api>();

  Future<void> loadAll() async {
    loading.value = true;
    error.value = null;
    try {
      final list = await api.listMyLibraries();
      myLibraries.assignAll(list.where((e) => !e.isSystem));
      readingRecord.value = await api.getReadingRecordLibrary();
      virtualMyUploaded.value = await api.getVirtualMyUploadedLibrary();
      _initialized = true;
    } catch (e) {
      final msg = _extractMessage(e) ?? '加载媒体库失败';
      error.value = msg;
    } finally {
      loading.value = false;
    }
  }

  Future<void> createLibrary(
    String name, {
    String? description,
    bool isPublic = false,
    List<LibraryTagDto> tags = const [],
  }) async {
    // 若服务尚未初始化则先尝试初始化（避免首次直接创建时列表未加载）
    if (!_initialized && !loading.value) {
      await loadAll();
    }
    try {
      final created = await api.createLibrary(
        CreateLibraryRequest(
          name: name,
          description: description,
          isPublic: isPublic,
          tags: tags,
        ),
      );
      myLibraries.insert(0, created);
      SideBanner.info('已创建媒体库');
    } catch (e) {
      final msg = _extractMessage(e) ?? '创建失败';
      SideBanner.danger(msg);
    }
  }

  Future<void> deleteLibrary(int id) async {
    try {
      await api.deleteLibrary(id);
      myLibraries.removeWhere((e) => e.id == id);
      SideBanner.info('已删除媒体库');
    } catch (e) {
      final msg = _extractMessage(e) ?? '删除失败';
      SideBanner.danger(msg);
    }
  }

  Future<void> updateLibrary(int id, UpdateLibraryRequest req) async {
    try {
      final updated = await api.updateLibrary(id, req);
      final idx = myLibraries.indexWhere((e) => e.id == id);
      if (idx >= 0) myLibraries[idx] = updated;
      SideBanner.info('已更新媒体库');
    } catch (e) {
      final msg = _extractMessage(e) ?? '更新失败';
      SideBanner.danger(msg);
    }
  }

  Future<void> addBookToLibrary(int libraryId, int bookId) async {
    // 收藏操作也可能在服务尚未初始化时发生，确保一次初始化
    if (!_initialized && !loading.value) {
      await loadAll();
    }
    try {
      await api.addBook(libraryId, bookId); // 返回条目，忽略内容
      // 二次拉取最新库数据
      final refreshed = await api.getLibrary(libraryId);
      final idx = myLibraries.indexWhere((e) => e.id == libraryId);
      if (idx >= 0) {
        myLibraries[idx] = refreshed;
      } else {
        // 若之前列表没有（例如首次收藏后创建的系统库），追加
        myLibraries.add(refreshed);
      }
      SideBanner.info('已收藏到媒体库');
    } catch (e) {
      final msg = _extractMessage(e) ?? '收藏失败';
      SideBanner.danger(msg);
    }
  }

  /// 对外暴露的初始化保障，可在其他地方显式调用
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (loading.value) return; // 已在加载中则等待外部监听
    await loadAll();
  }

  /// 提取后端异常 message 字段（支持 DioError/BooksApiError/通用 Exception）
  String? _extractMessage(Object e) {
    // 1. 处理自定义 ApiError
    if (e is Exception && e.toString().isNotEmpty) {
      // 兼容 BooksApiError、AuthApiError 等
      return e.toString();
    }
    // 2. 处理 DioError
    try {
      // DioError 结构兼容
      final dynamic err = e;
      if (err.response != null && err.response.data != null) {
        final data = err.response.data;
        if (data is Map &&
            data['message'] is String &&
            data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
      }
    } catch (_) {}
    // 3. 兜底
    return null;
  }
}
