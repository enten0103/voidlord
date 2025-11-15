class RecommendationSectionDto {
  final int id;
  final String key;
  final String title;
  final String? description;
  final bool active;
  final int sortOrder;
  final int mediaLibraryId;
  final String? mediaLibraryName; // 补充展示用
  RecommendationSectionDto({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.active,
    required this.sortOrder,
    required this.mediaLibraryId,
    required this.mediaLibraryName,
  });
  factory RecommendationSectionDto.fromJson(Map<String, dynamic> json) {
    final lib = json['library'];
    int libId = 0;
    String? libName;
    if (lib is Map) {
      if (lib['id'] is num) libId = (lib['id'] as num).toInt();
      if (lib['name'] is String) libName = lib['name'] as String;
    }
    return RecommendationSectionDto(
      id: (json['id'] as num).toInt(),
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      active: json['active'] == true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      mediaLibraryId: libId,
      mediaLibraryName: libName,
    );
  }
}

class CreateSectionRequest {
  final String key;
  final String title;
  final int mediaLibraryId;
  final String? description;
  final bool? active;
  final int? sortOrder;
  CreateSectionRequest({
    required this.key,
    required this.title,
    required this.mediaLibraryId,
    this.description,
    this.active,
    this.sortOrder,
  });
  Map<String, dynamic> toJson() => {
    'key': key,
    'title': title,
    'mediaLibraryId': mediaLibraryId,
    if (description != null) 'description': description,
    if (active != null) 'active': active,
    if (sortOrder != null) 'sort_order': sortOrder,
  };
}

class UpdateSectionRequest {
  final String? title;
  final String? description;
  final bool? active;
  final int? mediaLibraryId;
  final List<int>? sectionOrder; // 批量重排
  UpdateSectionRequest({
    this.title,
    this.description,
    this.active,
    this.mediaLibraryId,
    this.sectionOrder,
  });
  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (active != null) 'active': active,
    if (mediaLibraryId != null) 'mediaLibraryId': mediaLibraryId,
    if (sectionOrder != null) 'sectionOrder': sectionOrder,
  };
}
