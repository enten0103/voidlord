import 'package:flutter/foundation.dart';

class MediaLibraryDto {
  final int id;
  final String name;
  final String? description;
  final bool isPublic;
  final bool isSystem;
  final bool isVirtual; // 虚拟库（如我的上传）
  final int? ownerId;
  final int itemsCount;
  final List<MediaLibraryItemDto> items;
  final List<LibraryTagDto> tags;
  final int? copiedFrom; // 复制来源 id
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MediaLibraryDto({
    required this.id,
    required this.name,
    required this.description,
    required this.isPublic,
    required this.isSystem,
    required this.isVirtual,
    required this.ownerId,
    required this.itemsCount,
    required this.items,
    required this.tags,
    required this.copiedFrom,
    this.createdAt,
    this.updatedAt,
  });

  factory MediaLibraryDto.fromJson(Map<String, dynamic> json) {
    try {
      // 安全解析 items_count：后端可能未返回该字段（null），旧实现会对 null 进行 num 强转
      final dynamic itemsCountRaw = json['items_count'];
      final int safeItemsCount = itemsCountRaw is num ? itemsCountRaw.toInt() : 0;

      return MediaLibraryDto(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        description: json['description'] as String?,
        isPublic: json['is_public'] == true,
        isSystem: json['is_system'] == true,
        isVirtual: json['is_virtual'] == true,
        ownerId: json['owner_id'] == null ? null : (json['owner_id'] as num).toInt(),
        itemsCount: safeItemsCount,
        items: (json['items'] as List? ?? [])
            .whereType<Map>()
            .map((e) => MediaLibraryItemDto.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        tags: (json['tags'] as List? ?? [])
            .whereType<Map>()
            .map((e) => LibraryTagDto.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        copiedFrom: json['copied_from'] == null ? null : (json['copied_from'] as num).toInt(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );
    } catch (e, st) {
      debugPrint('MediaLibraryDto.fromJson error: $e');
      debugPrint('Stack: $st');
      debugPrint('Source JSON: $json');
      rethrow; // 继续抛出以便上层逻辑感知，但日志已记录
    }
  }
}

class MediaLibraryItemDto {
  final int id;
  final SimpleBookRef? book;
  final ChildLibraryRef? childLibrary;

  MediaLibraryItemDto({
    required this.id,
    required this.book,
    required this.childLibrary,
  });

  factory MediaLibraryItemDto.fromJson(Map<String, dynamic> json) =>
      MediaLibraryItemDto(
        id: (json['id'] as num).toInt(),
        book: json['book'] == null
            ? null
            : SimpleBookRef.fromJson(
                Map<String, dynamic>.from(json['book'] as Map),
              ),
        childLibrary: json['child_library'] == null
            ? null
            : ChildLibraryRef.fromJson(
                Map<String, dynamic>.from(json['child_library'] as Map),
              ),
      );
}

class SimpleBookRef {
  final int id;
  SimpleBookRef({required this.id});
  factory SimpleBookRef.fromJson(Map<String, dynamic> json) =>
      SimpleBookRef(id: (json['id'] as num).toInt());
}

class ChildLibraryRef {
  final int id;
  final String? name;
  ChildLibraryRef({required this.id, this.name});
  factory ChildLibraryRef.fromJson(Map<String, dynamic> json) =>
      ChildLibraryRef(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String?,
      );
}

class LibraryTagDto {
  final String key;
  final String value;
  final bool shown;
  LibraryTagDto({required this.key, required this.value, required this.shown});
  factory LibraryTagDto.fromJson(Map<String, dynamic> json) => LibraryTagDto(
    key: json['key'] as String,
    value: json['value'] as String,
    shown: json['shown'] == true,
  );
  Map<String, dynamic> toJson() => {'key': key, 'value': value, 'shown': shown};
}

class CreateLibraryRequest {
  final String name;
  final String? description;
  final bool isPublic;
  final List<LibraryTagDto> tags;
  CreateLibraryRequest({
    required this.name,
    this.description,
    required this.isPublic,
    required this.tags,
  });
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'is_public': isPublic,
    'tags': tags.map((e) => e.toJson()).toList(),
  }..removeWhere((k, v) => v == null);
}

class UpdateLibraryRequest {
  final String? name;
  final String? description;
  final bool? isPublic;
  final List<LibraryTagDto>? tags; // 覆盖策略
  UpdateLibraryRequest({this.name, this.description, this.isPublic, this.tags});
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (isPublic != null) 'is_public': isPublic,
    if (tags != null) 'tags': tags!.map((e) => e.toJson()).toList(),
  };
}
