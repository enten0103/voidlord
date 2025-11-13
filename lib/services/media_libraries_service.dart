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

  Api get api => Get.find<Api>();

  Future<void> loadAll() async {
    loading.value = true;
    error.value = null;
    try {
      final list = await api.listMyLibraries();
      myLibraries.assignAll(list.where((e) => !e.isSystem));
      readingRecord.value = await api.getReadingRecordLibrary();
      virtualMyUploaded.value = await api.getVirtualMyUploadedLibrary();
    } catch (e) {
      error.value = '加载媒体库失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> createLibrary(String name, {String? description, bool isPublic = false, List<LibraryTagDto> tags = const []}) async {
    try {
      final created = await api.createLibrary(CreateLibraryRequest(name: name, description: description, isPublic: isPublic, tags: tags));
      myLibraries.insert(0, created);
      SideBanner.info('已创建媒体库');
    } catch (e) {
      SideBanner.danger('创建失败');
    }
  }

  Future<void> deleteLibrary(int id) async {
    try {
      await api.deleteLibrary(id);
      myLibraries.removeWhere((e) => e.id == id);
      SideBanner.info('已删除媒体库');
    } catch (e) {
      SideBanner.danger('删除失败');
    }
  }

  Future<void> updateLibrary(int id, UpdateLibraryRequest req) async {
    try {
      final updated = await api.updateLibrary(id, req);
      final idx = myLibraries.indexWhere((e) => e.id == id);
      if (idx >= 0) myLibraries[idx] = updated;
      SideBanner.info('已更新媒体库');
    } catch (e) {
      SideBanner.danger('更新失败');
    }
  }
}
