import 'package:dio/dio.dart';
import 'client.dart';
import '../models/book_models.dart';

class BooksApiError implements Exception {
  final String message;
  final int? statusCode;
  BooksApiError(this.message, {this.statusCode});
  @override
  String toString() => message;
}

extension BooksApi on Api {
  // 列出所有图书，可选按标签过滤: tags=author,genre
  Future<List<BookDto>> listBooks({List<String>? tags}) async {
    final Response res = await client.get(
      '/books',
      queryParameters: {
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
      },
    );
    if (res.statusCode == 200 && res.data is List) {
      return (res.data as List)
          .whereType<Map>()
          .map((e) => BookDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw BooksApiError('获取图书列表失败', statusCode: res.statusCode);
  }

  // 获取本人上传的图书 /books/my 需要登录
  Future<List<BookDto>> listMyBooks() async {
    final Response res = await client.get('/books/my');
    if (res.statusCode == 200 && res.data is List) {
      return (res.data as List)
          .whereType<Map>()
          .map((e) => BookDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (res.statusCode == 401) {
      throw BooksApiError('未登录', statusCode: 401);
    }
    throw BooksApiError('获取我的图书失败', statusCode: res.statusCode);
  }

  // 根据 ID 获取图书
  Future<BookDto> getBook(int id) async {
    final Response res = await client.get('/books/$id');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return BookDto.fromJson(res.data as Map<String, dynamic>);
    }
    if (res.statusCode == 404) {
      throw BooksApiError('图书不存在', statusCode: 404);
    }
    throw BooksApiError('获取图书失败', statusCode: res.statusCode);
  }

  // 创建图书 (仅 tags)
  Future<BookDto> createBook(CreateBookRequest req) async {
    final Response res = await client.post('/books', data: req.toJson());
    if ((res.statusCode == 200 || res.statusCode == 201) &&
        res.data is Map<String, dynamic>) {
      return BookDto.fromJson(res.data as Map<String, dynamic>);
    }
    if (res.statusCode == 401) throw BooksApiError('未登录', statusCode: 401);
    if (res.statusCode == 403) throw BooksApiError('权限不足', statusCode: 403);
    if (res.statusCode == 409) {
      throw BooksApiError('冲突: 标签或数据不合法', statusCode: 409);
    }
    throw BooksApiError('创建图书失败', statusCode: res.statusCode);
  }

  // 更新图书 (覆盖标签列表)
  Future<BookDto> updateBook(int id, UpdateBookRequest req) async {
    final Response res = await client.patch('/books/$id', data: req.toJson());
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return BookDto.fromJson(res.data as Map<String, dynamic>);
    }
    switch (res.statusCode) {
      case 401:
        throw BooksApiError('未登录', statusCode: 401);
      case 403:
        throw BooksApiError('权限不足', statusCode: 403);
      case 404:
        throw BooksApiError('图书不存在', statusCode: 404);
      case 409:
        throw BooksApiError('数据冲突', statusCode: 409);
    }
    throw BooksApiError('更新图书失败', statusCode: res.statusCode);
  }

  // 删除图书
  Future<bool> deleteBook(int id) async {
    final Response res = await client.delete('/books/$id');
    if ((res.statusCode == 200 || res.statusCode == 201) &&
        res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      return map['ok'] == true;
    }
    switch (res.statusCode) {
      case 401:
        throw BooksApiError('未登录', statusCode: 401);
      case 403:
        throw BooksApiError('权限不足', statusCode: 403);
      case 404:
        throw BooksApiError('图书不存在', statusCode: 404);
    }
    throw BooksApiError('删除失败', statusCode: res.statusCode);
  }

  // 推荐图书 (简易) /books/recommend/:id?limit=5
  Future<List<BookDto>> recommendBooks(int id, {int limit = 5}) async {
    final Response res = await client.get(
      '/books/recommend/$id',
      queryParameters: {'limit': limit},
    );
    if (res.statusCode == 200 && res.data is List) {
      return (res.data as List)
          .whereType<Map>()
          .map((e) => BookDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw BooksApiError('获取推荐失败', statusCode: res.statusCode);
  }

  /// 新标签条件搜索 POST /books/search
  /// 兼容两种响应：
  /// 1) 未分页: 直接返回 List\<BookDto\>
  /// 2) 分页: 返回 { total, limit, offset, items: [...] }
  Future<BookSearchResponse> searchBooks({
    required List<BookSearchCondition> conditions,
    int? limit,
    int? offset,
    String? sort,
  }) async {
    final body = <String, dynamic>{};
    if (conditions.isNotEmpty) {
      body['conditions'] = conditions.map((e) => e.toJson()).toList();
    }
    if (limit != null) body['limit'] = limit;
    if (offset != null) body['offset'] = offset;
    if (sort != null) body['sort'] = sort;
    final Response res = await client.post('/books/search', data: body);
    if (res.statusCode == 201) {
      // 分页对象
      if (res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        final items = (map['items'] as List? ?? [])
            .whereType<Map>()
            .map((e) => BookDto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return BookSearchResponse(
          items: items,
          total: (map['total'] is num) ? (map['total'] as num).toInt() : null,
          limit: (map['limit'] is num) ? (map['limit'] as num).toInt() : null,
          offset: (map['offset'] is num)
              ? (map['offset'] as num).toInt()
              : null,
        );
      }
      // 直接数组
      if (res.data is List) {
        final list = (res.data as List)
            .whereType<Map>()
            .map((e) => BookDto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return BookSearchResponse(items: list);
      }
    }
    if (res.statusCode == 400) {
      throw BooksApiError('搜索参数不合法', statusCode: 400);
    }
    throw BooksApiError('搜索失败', statusCode: res.statusCode);
  }

  // 评分 POST /books/:id/rating { score: 1-5 }
  Future<RatingResponse> rateBook(int id, int score) async {
    final Response res = await client.post(
      '/books/$id/rating',
      data: {'score': score},
    );
    if ((res.statusCode == 200 || res.statusCode == 201) &&
        res.data is Map<String, dynamic>) {
      return RatingResponse.fromJson(res.data as Map<String, dynamic>);
    }
    switch (res.statusCode) {
      case 401:
        throw BooksApiError('未登录', statusCode: 401);
      case 404:
        throw BooksApiError('图书不存在', statusCode: 404);
      case 409:
        throw BooksApiError('评分不合法', statusCode: 409);
    }
    throw BooksApiError('评分失败', statusCode: res.statusCode);
  }

  // 获取评分 GET /books/:id/rating (若后端存在此端点) 可选；返回 myRating=0 表示当前用户未评分
  Future<RatingResponse?> getBookRating(int id) async {
    try {
      final Response res = await client.get('/books/$id/rating');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return RatingResponse.fromJson(res.data as Map<String, dynamic>);
      }
      if (res.statusCode == 404) {
        // 评分不存在或图书不存在；返回 null 由上层决定是否显示
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
    return null;
  }

  // 顶层评论列表
  Future<CommentsList> listComments(
    int bookId, {
    int? limit,
    int? offset,
  }) async {
    final Response res = await client.get(
      '/books/$bookId/comments',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return CommentsList.fromJson(res.data as Map<String, dynamic>);
    }
    if (res.statusCode == 404) {
      throw BooksApiError('图书不存在', statusCode: 404);
    }
    throw BooksApiError('获取评论失败', statusCode: res.statusCode);
  }

  // 新增顶层评论
  Future<CommentCreateResponse> createComment(
    int bookId,
    String content,
  ) async {
    final Response res = await client.post(
      '/books/$bookId/comments',
      data: {'content': content},
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (res.data is Map<String, dynamic>) {
        return CommentCreateResponse.fromJson(res.data as Map<String, dynamic>);
      }
    }
    switch (res.statusCode) {
      case 401:
        throw BooksApiError('未登录', statusCode: 401);
      case 404:
        throw BooksApiError('图书不存在', statusCode: 404);
      case 409:
        throw BooksApiError('内容不合法', statusCode: 409);
    }
    throw BooksApiError('创建评论失败', statusCode: res.statusCode);
  }

  // 回复某条评论
  Future<CommentCreateResponse> replyComment(
    int bookId,
    int commentId,
    String content,
  ) async {
    final Response res = await client.post(
      '/books/$bookId/comments/$commentId/replies',
      data: {'content': content},
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (res.data is Map<String, dynamic>) {
        return CommentCreateResponse.fromJson(res.data as Map<String, dynamic>);
      }
    }
    switch (res.statusCode) {
      case 401:
        throw BooksApiError('未登录', statusCode: 401);
      case 404:
        throw BooksApiError('图书或父评论不存在', statusCode: 404);
      case 409:
        throw BooksApiError('内容不合法', statusCode: 409);
    }
    throw BooksApiError('回复失败', statusCode: res.statusCode);
  }

  // 列出某条评论的回复
  Future<RepliesList> listReplies(
    int bookId,
    int commentId, {
    int? limit,
    int? offset,
  }) async {
    final Response res = await client.get(
      '/books/$bookId/comments/$commentId/replies',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return RepliesList.fromJson(res.data as Map<String, dynamic>);
    }
    switch (res.statusCode) {
      case 404:
        throw BooksApiError('图书或评论不存在', statusCode: 404);
    }
    throw BooksApiError('获取回复失败', statusCode: res.statusCode);
  }

  // 删除评论 /books/:id/comments/:commentId
  Future<bool> deleteComment(int bookId, int commentId) async {
    final Response res = await client.delete(
      '/books/$bookId/comments/$commentId',
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      return map['ok'] == true;
    }
    switch (res.statusCode) {
      case 401:
        throw BooksApiError('未登录', statusCode: 401);
      case 403:
        throw BooksApiError('无权删除该评论', statusCode: 403);
      case 404:
        throw BooksApiError('图书或评论不存在', statusCode: 404);
    }
    throw BooksApiError('删除评论失败', statusCode: res.statusCode);
  }
}

// 搜索条件模型
class BookSearchCondition {
  final String id;
  final String target; // tag key
  final String op; // eq | neq | match
  final String value;
  BookSearchCondition({
    String? id,
    required this.target,
    required this.op,
    required this.value,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    // 后端采用大写枚举风格 (e.g. TITLE / AUTHOR / COVER)，统一向上层发送大写
    'target': target.toUpperCase(),
    'op': op,
    'value': value,
  };
}

// 搜索响应统一封装（分页或非分页）
class BookSearchResponse {
  final List<BookDto> items;
  final int? total;
  final int? limit;
  final int? offset;
  bool get paged => total != null && limit != null && offset != null;
  BookSearchResponse({
    required this.items,
    this.total,
    this.limit,
    this.offset,
  });
}
