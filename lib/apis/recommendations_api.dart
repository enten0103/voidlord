import 'client.dart';
import '../models/recommendations_models.dart';

extension RecommendationsApi on Api {
  Future<List<RecommendationSectionDto>> listSections({
    bool all = false,
  }) async {
    final path = all
        ? '/recommendations/sections?all=true'
        : '/recommendations/sections';
    final resp = await client.get(path);
    return (resp.data as List? ?? [])
        .whereType<Map>()
        .map(
          (e) =>
              RecommendationSectionDto.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<RecommendationSectionDto> createSection(
    CreateSectionRequest req,
  ) async {
    final resp = await client.post(
      '/recommendations/sections',
      data: req.toJson(),
    );
    return RecommendationSectionDto.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<RecommendationSectionDto> updateSection(
    int id,
    UpdateSectionRequest req,
  ) async {
    final resp = await client.patch(
      '/recommendations/sections/$id',
      data: req.toJson(),
    );
    return RecommendationSectionDto.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteSection(int id) async {
    await client.delete('/recommendations/sections/$id');
  }

  // 批量重排：根据指南，PATCH 任意 section id 携带 sectionOrder 列表即可
  Future<List<RecommendationSectionDto>> reorderSections(
    List<int> orderedIds,
  ) async {
    if (orderedIds.isEmpty) return [];
    final first = orderedIds.first;
    await client.patch(
      '/recommendations/sections/$first',
      data: UpdateSectionRequest(sectionOrder: orderedIds).toJson(),
    );
    // 服务端可能只返回被操作的一个 Section，这里重新拉取全部列表
    final refreshed = await listSections(all: true);
    return refreshed;
  }
}
