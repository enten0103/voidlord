import 'package:get/get.dart';
import 'package:voidlord/apis/client.dart';
import 'package:voidlord/apis/recommendations_api.dart';
import 'package:voidlord/models/recommendations_models.dart';
import 'package:voidlord/services/media_libraries_service.dart';
import 'package:voidlord/models/media_library_models.dart';
import 'package:voidlord/apis/media_library_api.dart';

class SquareController extends GetxController {
  final loading = false.obs;
  final error = RxnString();
  final sections = <RecommendationSectionDto>[].obs;
  final libraries = <int, MediaLibraryDto>{}.obs; // libraryId -> full dto
  final itemsLoading = false.obs; // 条目批量加载中

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
    final ids = sections.map((e) => e.mediaLibraryId).where((id) => id > 0).toSet();
    final need = ids.where((id) => !libraries.containsKey(id)).toList();
    if (need.isEmpty) return;
    itemsLoading.value = true;
    try {
      final futures = need.map((id) => api.getLibrary(id));
      final results = await Future.wait(futures);
      for (final lib in results) {
        libraries[lib.id] = lib;
      }
    } catch (_) {
      // 忽略局部失败，保留已加载内容
    } finally {
      itemsLoading.value = false;
    }
  }

  List<MediaLibraryItemDto> itemsFor(int libraryId) {
    final lib = libraries[libraryId];
    return lib?.items ?? const [];
  }
}
