import 'package:dio/dio.dart';
import 'client.dart';
import '../models/file_models.dart';

extension FilesApi on Api {
  // GET /files/upload-url
  Future<PresignedUrlResponse> getUploadUrl({
    required String key,
    String? contentType,
  }) async {
    final Response res = await client.get(
      '/files/upload-url',
      queryParameters: {
        'key': key,
        if (contentType != null) 'contentType': contentType,
      },
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return PresignedUrlResponse.fromJson(res.data as Map<String, dynamic>);
    }
    if (res.statusCode == 401) throw FilesApiError('未登录', statusCode: 401);
    throw FilesApiError('获取上传 URL 失败', statusCode: res.statusCode);
  }

  // POST /files/upload (multipart)
  Future<UploadResultDto> uploadMultipart(FormData formData) async {
    final Response res = await client.post('/files/upload', data: formData);
    if ((res.statusCode == 200 || res.statusCode == 201) &&
        res.data is Map<String, dynamic>) {
      return UploadResultDto.fromJson(res.data as Map<String, dynamic>);
    }
    if (res.statusCode == 401) throw FilesApiError('未登录', statusCode: 401);
    throw FilesApiError('上传失败', statusCode: res.statusCode);
  }

  // GET /files/download-url
  Future<PresignedUrlResponse> getDownloadUrl({
    required String key,
    int? expiresIn,
  }) async {
    final Response res = await client.get(
      '/files/download-url',
      queryParameters: {
        'key': key,
        if (expiresIn != null) 'expiresIn': expiresIn,
      },
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return PresignedUrlResponse.fromJson(res.data as Map<String, dynamic>);
    }
    if (res.statusCode == 401) throw FilesApiError('未登录', statusCode: 401);
    throw FilesApiError('获取下载 URL 失败', statusCode: res.statusCode);
  }

  // DELETE /files/object
  Future<bool> deleteObject({required String key}) async {
    final Response res = await client.delete(
      '/files/object',
      queryParameters: {'key': key},
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      return map['ok'] == true;
    }
    switch (res.statusCode) {
      case 401:
        throw FilesApiError('未登录', statusCode: 401);
      case 403:
        throw FilesApiError('权限不足 (仅本人或 FILE_MANAGE)', statusCode: 403);
      case 404:
        throw FilesApiError('对象不存在', statusCode: 404);
    }
    throw FilesApiError('删除失败', statusCode: res.statusCode);
  }

  // POST /files/policy/public
  Future<OkMessageResponse> setBucketPublic() async {
    final Response res = await client.post('/files/policy/public');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return OkMessageResponse.fromJson(res.data as Map<String, dynamic>);
    }
    switch (res.statusCode) {
      case 401:
        throw FilesApiError('未登录', statusCode: 401);
      case 403:
        throw FilesApiError('需要 SYS_MANAGE(>=3)', statusCode: 403);
    }
    throw FilesApiError('设置公开失败', statusCode: res.statusCode);
  }

  // POST /files/policy/private
  Future<OkMessageResponse> setBucketPrivate() async {
    final Response res = await client.post('/files/policy/private');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return OkMessageResponse.fromJson(res.data as Map<String, dynamic>);
    }
    switch (res.statusCode) {
      case 401:
        throw FilesApiError('未登录', statusCode: 401);
      case 403:
        throw FilesApiError('需要 SYS_MANAGE(>=3)', statusCode: 403);
    }
    throw FilesApiError('设置私有失败', statusCode: res.statusCode);
  }
}
