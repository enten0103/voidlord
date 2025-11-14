import 'package:get/get.dart';
import '../../apis/client.dart';
import '../../services/media_libraries_service.dart';

/// 推荐槽位：每个槽位指向一个媒体库（书单）
class RecommendationSlot {
  final int id; // 槽位ID
  int? libraryId; // 指向的媒体库ID
  String? libraryName; // 便于展示
  RecommendationSlot({required this.id, this.libraryId, this.libraryName});
}

class RecommendationsController extends GetxController {
  final loading = false.obs;
  final saving = false.obs;
  final error = RxnString();
  final slots = <RecommendationSlot>[].obs;

  Api get api => Get.find<Api>();
  MediaLibrariesService get libs => Get.find<MediaLibrariesService>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      // TODO: 调用后端推荐槽位列表接口。占位模拟 5 个槽位，其中部分为空。
      await Future.delayed(const Duration(milliseconds: 200));
      slots.assignAll([
        RecommendationSlot(id: 1, libraryId: libs.readingRecord.value?.id, libraryName: libs.readingRecord.value?.name),
        RecommendationSlot(id: 2, libraryId: libs.myLibraries.isNotEmpty ? libs.myLibraries[0].id : null, libraryName: libs.myLibraries.isNotEmpty ? libs.myLibraries[0].name : null),
        RecommendationSlot(id: 3),
        RecommendationSlot(id: 4),
        RecommendationSlot(id: 5),
      ]);
    } catch (e) {
      error.value = '加载推荐槽位失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateSlotLibrary(int slotId, int? newLibraryId) async {
    saving.value = true;
    try {
      // TODO: 调用后端更新接口: api.updateRecommendation(slotId, newLibraryId)
      await Future.delayed(const Duration(milliseconds: 150));
      final lib = libs.myLibraries.firstWhereOrNull((e) => e.id == newLibraryId);
      final idx = slots.indexWhere((s) => s.id == slotId);
      if (idx >= 0) {
        slots[idx] = RecommendationSlot(
          id: slotId,
          libraryId: newLibraryId,
            libraryName: lib?.name,
        );
      }
    } catch (e) {
      error.value = '更新槽位失败';
    } finally {
      saving.value = false;
    }
  }
}
