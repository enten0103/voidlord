import 'client.dart';
import '../models/media_library_models.dart';

extension MediaLibraryApi on Api {
  Future<MediaLibraryDto> createLibrary(CreateLibraryRequest req) async {
    final resp = await client.post('/media-libraries', data: req.toJson());
    return MediaLibraryDto.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<MediaLibraryDto>> listMyLibraries() async {
    final resp = await client.get('/media-libraries/my');
    return (resp.data as List? ?? [])
        .whereType<Map>()
        .map((e) => MediaLibraryDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<MediaLibraryDto> getLibrary(int id, {int? limit, int? offset}) async {
    final qs = _buildPageQS(limit, offset);
    final resp = await client.get('/media-libraries/$id$qs');
    return MediaLibraryDto.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MediaLibraryDto> getReadingRecordLibrary({
    int? limit,
    int? offset,
  }) async {
    final qs = _buildPageQS(limit, offset);
    final resp = await client.get('/media-libraries/reading-record$qs');
    return MediaLibraryDto.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MediaLibraryDto> getVirtualMyUploadedLibrary({
    int? limit,
    int? offset,
  }) async {
    final qs = _buildPageQS(limit, offset);
    final resp = await client.get('/media-libraries/virtual/my-uploaded$qs');
    return MediaLibraryDto.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 添加书籍到媒体库：返回的是新增的条目（后端未返回整个库），需要调用者自行刷新库
  Future<MediaLibraryItemDto> addBook(int libraryId, int bookId) async {
    final resp = await client.post('/media-libraries/$libraryId/books/$bookId');
    final raw = resp.data as Map<String, dynamic>;
    return MediaLibraryItemDto(
      id: (raw['id'] as num).toInt(),
      book: raw['bookId'] == null
          ? null
          : SimpleBookRef(id: (raw['bookId'] as num).toInt()),
      childLibrary: null,
    );
  }

  Future<MediaLibraryDto> addChildLibrary(int libraryId, int childId) async {
    final resp = await client.post(
      '/media-libraries/$libraryId/libraries/$childId',
    );
    return MediaLibraryDto.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> removeItem(int libraryId, int itemId) async {
    await client.delete('/media-libraries/$libraryId/items/$itemId');
  }

  Future<MediaLibraryDto> updateLibrary(
    int id,
    UpdateLibraryRequest req,
  ) async {
    final resp = await client.patch('/media-libraries/$id', data: req.toJson());
    return MediaLibraryDto.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MediaLibraryDto> copyLibrary(int id) async {
    final resp = await client.post('/media-libraries/$id/copy');
    return MediaLibraryDto.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteLibrary(int id) async {
    await client.delete('/media-libraries/$id');
  }

  String _buildPageQS(int? limit, int? offset) {
    if (limit == null && offset == null) return '';
    final params = <String, String>{};
    if (limit != null) params['limit'] = '$limit';
    if (offset != null) params['offset'] = '$offset';
    return '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
  }
}
