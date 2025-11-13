import 'client.dart';
import '../models/media_library_models.dart';

extension MediaLibraryApi on Api {
  Future<MediaLibraryDto> createLibrary(CreateLibraryRequest req) async {
    final resp = await client.post('/media-libraries', data: req.toJson());
    return MediaLibraryDto.fromJson(resp.data as Map<String,dynamic>);
  }

  Future<List<MediaLibraryDto>> listMyLibraries() async {
    final resp = await client.get('/media-libraries/my');
    return (resp.data as List? ?? [])
      .whereType<Map>()
      .map((e) => MediaLibraryDto.fromJson(Map<String,dynamic>.from(e)))
      .toList();
  }

  Future<MediaLibraryDto> getLibrary(int id) async {
    final resp = await client.get('/media-libraries/$id');
    return MediaLibraryDto.fromJson(resp.data as Map<String,dynamic>);
  }

  Future<MediaLibraryDto> getReadingRecordLibrary() async {
    final resp = await client.get('/media-libraries/reading-record');
    return MediaLibraryDto.fromJson(resp.data as Map<String,dynamic>);
  }

  Future<MediaLibraryDto> getVirtualMyUploadedLibrary() async {
    final resp = await client.get('/media-libraries/virtual/my-uploaded');
    return MediaLibraryDto.fromJson(resp.data as Map<String,dynamic>);
  }

  Future<MediaLibraryDto> addBook(int libraryId, int bookId) async {
    final resp = await client.post('/media-libraries/$libraryId/books/$bookId');
    return MediaLibraryDto.fromJson(resp.data as Map<String,dynamic>);
  }

  Future<MediaLibraryDto> addChildLibrary(int libraryId, int childId) async {
    final resp = await client.post('/media-libraries/$libraryId/libraries/$childId');
    return MediaLibraryDto.fromJson(resp.data as Map<String,dynamic>);
  }

  Future<void> removeItem(int libraryId, int itemId) async {
    await client.delete('/media-libraries/$libraryId/items/$itemId');
  }

  Future<MediaLibraryDto> updateLibrary(int id, UpdateLibraryRequest req) async {
    final resp = await client.patch('/media-libraries/$id', data: req.toJson());
    return MediaLibraryDto.fromJson(resp.data as Map<String,dynamic>);
  }

  Future<MediaLibraryDto> copyLibrary(int id) async {
    final resp = await client.post('/media-libraries/$id/copy');
    return MediaLibraryDto.fromJson(resp.data as Map<String,dynamic>);
  }

  Future<void> deleteLibrary(int id) async {
    await client.delete('/media-libraries/$id');
  }
}
