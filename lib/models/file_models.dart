class PresignedUrlResponse {
  final String url;
  final String key;
  PresignedUrlResponse({required this.url, required this.key});
  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) =>
      PresignedUrlResponse(url: json['url'] as String, key: json['key'] as String);
  Map<String, dynamic> toJson() => {'url': url, 'key': key};
}

class UploadResultDto {
  final bool ok;
  final String key;
  final int size;
  final String? mime;
  final String? url; // 可能返回公开 URL
  UploadResultDto({
    required this.ok,
    required this.key,
    required this.size,
    this.mime,
    this.url,
  });
  factory UploadResultDto.fromJson(Map<String, dynamic> json) => UploadResultDto(
        ok: json['ok'] == true,
        key: json['key'] as String,
        size: (json['size'] as num).toInt(),
        mime: json['mime'] as String?,
        url: json['url'] as String?,
      );
  Map<String, dynamic> toJson() => {
        'ok': ok,
        'key': key,
        'size': size,
        if (mime != null) 'mime': mime,
        if (url != null) 'url': url,
      };
}

class OkMessageResponse {
  final bool ok;
  final String? message;
  OkMessageResponse({required this.ok, this.message});
  factory OkMessageResponse.fromJson(Map<String, dynamic> json) =>
      OkMessageResponse(ok: json['ok'] == true, message: json['message'] as String?);
  Map<String, dynamic> toJson() => {
        'ok': ok,
        if (message != null) 'message': message,
      };
}

class FilesApiError implements Exception {
  final String message;
  final int? statusCode;
  FilesApiError(this.message, {this.statusCode});
  @override
  String toString() => message;
}
