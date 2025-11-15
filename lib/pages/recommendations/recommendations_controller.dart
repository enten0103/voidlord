import 'package:get/get.dart';
import '../../apis/client.dart';
import '../../apis/recommendations_api.dart';
import '../../services/media_libraries_service.dart';
import '../../models/recommendations_models.dart';
import '../../widgets/side_baner.dart';

/// 推荐分区管理控制器：支持加载、创建、更新、启用/停用、重排与删除
class RecommendationsController extends GetxController {
  final loading = false.obs; // 列表加载中
  final saving = false.obs; // 后端写操作中
  final creating = false.obs; // 创建中
  final error = RxnString();

  // 全量分区（始终加载全部，删除 showAll 状态逻辑）
  final sections = <RecommendationSectionDto>[].obs;
  final orderDirty = false.obs; // 是否存在未提交的排序更改

  Api get api => Get.find<Api>();
  MediaLibrariesService get libs => Get.find<MediaLibrariesService>();

  @override
  void onInit() {
    super.onInit();
    // 先确保媒体库服务已初始化，再加载分区
    Future.microtask(() async {
      await libs.ensureInitialized();
      await load();
    });
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      // 始终请求全部分区（包括 inactive）
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
      orderDirty.value = false;
    } catch (e) {
      error.value = '加载推荐分区失败';
    } finally {
      loading.value = false;
    }
  }

  // 页面直接使用全部分区（已包含 active / inactive）
  List<RecommendationSectionDto> get visibleSections =>
      (sections.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));

  Future<void> changeLibrary(int sectionId, int newLibraryId) async {
    saving.value = true;
    try {
      final updated = await api.updateSection(
        sectionId,
        UpdateSectionRequest(mediaLibraryId: newLibraryId),
      );
      _applyUpdated(updated);
      SideBanner.info('已切换库');
    } catch (e) {
      SideBanner.danger('切换库失败');
    } finally {
      saving.value = false;
    }
  }

  Future<void> toggleActive(int sectionId, bool active) async {
    saving.value = true;
    try {
      final updated = await api.updateSection(
        sectionId,
        UpdateSectionRequest(active: active),
      );
      _applyUpdated(updated);
    } catch (e) {
      SideBanner.danger('更新启用状态失败');
    } finally {
      saving.value = false;
    }
  }

  Future<void> updateTitleDesc(
    int sectionId,
    String title,
    String? desc,
  ) async {
    saving.value = true;
    try {
      final updated = await api.updateSection(
        sectionId,
        UpdateSectionRequest(title: title, description: desc),
      );
      _applyUpdated(updated);
      SideBanner.info('已更新');
    } catch (e) {
      SideBanner.danger('更新失败');
    } finally {
      saving.value = false;
    }
  }

  Future<void> createSection(
    String key,
    String title,
    int mediaLibraryId, {
    String? description,
    bool active = true,
  }) async {
    creating.value = true;
    try {
      final created = await api.createSection(
        CreateSectionRequest(
          key: key,
          title: title,
          mediaLibraryId: mediaLibraryId,
          description: description,
          active: active,
        ),
      );
      sections.add(created);
      sections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      SideBanner.info('创建成功');
    } catch (e) {
      SideBanner.danger('创建失败');
    } finally {
      creating.value = false;
    }
  }

  Future<void> deleteSection(int sectionId) async {
    saving.value = true;
    try {
      await api.deleteSection(sectionId);
      sections.removeWhere((s) => s.id == sectionId);
      SideBanner.info('已删除');
    } catch (e) {
      SideBanner.danger('删除失败');
    } finally {
      saving.value = false;
    }
  }

  void localReorder(int oldIndex, int newIndex) {
    final list = visibleSections; // 已过滤且排序
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      final s = list[i];
      final idx = sections.indexWhere((e) => e.id == s.id);
      if (idx >= 0) {
        sections[idx] = RecommendationSectionDto(
          id: s.id,
          key: s.key,
          title: s.title,
          description: s.description,
          active: s.active,
          sortOrder: i,
          mediaLibraryId: s.mediaLibraryId,
          mediaLibraryName: s.mediaLibraryName,
        );
      }
    }
    orderDirty.value = true;
  }

  Future<void> persistReorder() async {
    if (!orderDirty.value) return;
    saving.value = true;
    try {
      // 重排时提交全部分区的当前顺序
      final orderedIds =
          (sections.toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
              .map((e) => e.id)
              .toList();
      final refreshed = await api.reorderSections(orderedIds);
      sections.assignAll(refreshed);
      sections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      orderDirty.value = false;
      SideBanner.info('重排已保存');
    } catch (e) {
      SideBanner.danger('保存重排失败');
    } finally {
      saving.value = false;
    }
  }

  void _applyUpdated(RecommendationSectionDto updated) {
    final idx = sections.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) {
      sections[idx] = RecommendationSectionDto(
        id: updated.id,
        key: updated.key,
        title: updated.title,
        description: updated.description,
        active: updated.active,
        sortOrder: updated.sortOrder,
        mediaLibraryId: updated.mediaLibraryId,
        mediaLibraryName: updated.mediaLibraryName,
      );
      sections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
  }
}
