class TagDto {
  final int id;
  final String key;
  final String value;
  final bool shown;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TagDto({
    required this.id,
    required this.key,
    required this.value,
    required this.shown,
    this.createdAt,
    this.updatedAt,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) => TagDto(
    id: (json['id'] as num).toInt(),
    key: json['key'] as String,
    value: json['value'] as String,
    shown: json['shown'] == true,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString())
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'value': value,
    'shown': shown,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}

class TagInput {
  final String key;
  final String value;
  final bool shown;
  TagInput({required this.key, required this.value, this.shown = true});
  Map<String, dynamic> toJson() => {'key': key, 'value': value, 'shown': shown};
}

class BookDto {
  final int id;
  final int? createBy;
  final List<TagDto> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookDto({
    required this.id,
    required this.createBy,
    required this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory BookDto.fromJson(Map<String, dynamic> json) => BookDto(
    id: (json['id'] as num).toInt(),
    createBy: json['create_by'] == null
        ? null
        : (json['create_by'] as num).toInt(),
    tags: (json['tags'] as List? ?? [])
        .whereType<Map>()
        .map((e) => TagDto.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString())
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'create_by': createBy,
    'tags': tags.map((e) => e.toJson()).toList(),
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}

class CreateBookRequest {
  final List<TagInput> tags;
  CreateBookRequest({required this.tags});
  Map<String, dynamic> toJson() => {
    'tags': tags.map((e) => e.toJson()).toList(),
  };
}

class UpdateBookRequest {
  final List<TagInput> tags;
  UpdateBookRequest({required this.tags});
  Map<String, dynamic> toJson() => {
    'tags': tags.map((e) => e.toJson()).toList(),
  };
}

class RatingResponse {
  final bool ok;
  final int bookId;

  /// 当前用户评分；若服务端未返回则默认为 0 表示未评分
  final int myRating;

  /// 平均分；缺失时回退为 0.0
  final double avg;

  /// 总评分人数；缺失时回退为 0
  final int count;

  RatingResponse({
    required this.ok,
    required this.bookId,
    required this.myRating,
    required this.avg,
    required this.count,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) => RatingResponse(
    ok: json['ok'] == null ? true : json['ok'] == true,
    bookId: (json['bookId'] as num?)?.toInt() ?? 0,
    myRating: (json['myRating'] as num?)?.toInt() ?? 0,
    avg: (json['avg'] as num?)?.toDouble() ?? 0.0,
    count: (json['count'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'bookId': bookId,
    'myRating': myRating,
    'avg': avg,
    'count': count,
  };
}

class OkResponse {
  final bool ok;
  OkResponse({required this.ok});
  factory OkResponse.fromJson(Map<String, dynamic> json) =>
      OkResponse(ok: json['ok'] == true);
  Map<String, dynamic> toJson() => {'ok': ok};
}

class UserLite {
  final int id;
  final String username;
  UserLite({required this.id, required this.username});
  factory UserLite.fromJson(Map<String, dynamic> json) => UserLite(
    id: (json['id'] as num).toInt(),
    username: json['username'] as String,
  );
  Map<String, dynamic> toJson() => {'id': id, 'username': username};
}

class CommentDto {
  final int id;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserLite? user;
  final int? replyCount; // 仅顶层列表存在

  CommentDto({
    required this.id,
    required this.content,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.replyCount,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) => CommentDto(
    id: (json['id'] as num).toInt(),
    content: json['content'] as String,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString())
        : null,
    user: json['user'] == null
        ? null
        : UserLite.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    replyCount: json['reply_count'] == null
        ? null
        : (json['reply_count'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    if (user != null) 'user': user!.toJson(),
    if (replyCount != null) 'reply_count': replyCount,
  };
}

class CommentsList {
  final int bookId;
  final int total;
  final int limit;
  final int offset;
  final List<CommentDto> items;

  CommentsList({
    required this.bookId,
    required this.total,
    required this.limit,
    required this.offset,
    required this.items,
  });

  factory CommentsList.fromJson(Map<String, dynamic> json) => CommentsList(
    bookId: (json['bookId'] as num).toInt(),
    total: (json['total'] as num).toInt(),
    limit: (json['limit'] as num).toInt(),
    offset: (json['offset'] as num).toInt(),
    items: (json['items'] as List? ?? [])
        .whereType<Map>()
        .map((e) => CommentDto.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'total': total,
    'limit': limit,
    'offset': offset,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class RepliesList {
  final int bookId;
  final int parentId;
  final int total;
  final int limit;
  final int offset;
  final List<CommentDto> items;

  RepliesList({
    required this.bookId,
    required this.parentId,
    required this.total,
    required this.limit,
    required this.offset,
    required this.items,
  });

  factory RepliesList.fromJson(Map<String, dynamic> json) => RepliesList(
    bookId: (json['bookId'] as num).toInt(),
    parentId: (json['parentId'] as num).toInt(),
    total: (json['total'] as num).toInt(),
    limit: (json['limit'] as num).toInt(),
    offset: (json['offset'] as num).toInt(),
    items: (json['items'] as List? ?? [])
        .whereType<Map>()
        .map((e) => CommentDto.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'parentId': parentId,
    'total': total,
    'limit': limit,
    'offset': offset,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class CommentCreateResponse {
  final int id;
  final int bookId;
  final int? parentId;
  final String content;
  final DateTime? createdAt;

  CommentCreateResponse({
    required this.id,
    required this.bookId,
    this.parentId,
    required this.content,
    this.createdAt,
  });

  factory CommentCreateResponse.fromJson(Map<String, dynamic> json) =>
      CommentCreateResponse(
        id: (json['id'] as num).toInt(),
        bookId: (json['bookId'] as num).toInt(),
        parentId: json['parentId'] == null
            ? null
            : (json['parentId'] as num).toInt(),
        content: json['content'] as String,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    if (parentId != null) 'parentId': parentId,
    'content': content,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}
