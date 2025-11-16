import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AppConfig {
  final String baseUrl;
  final String minioUrl;
  final Map<String, dynamic> extras;

  const AppConfig({
    required this.baseUrl,
    required this.minioUrl,
    this.extras = const {},
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
    baseUrl: (json['baseUrl'] as String?)?.trim().isNotEmpty == true
        ? json['baseUrl'] as String
        : 'http://localhost:8080',
    minioUrl: (json['minioUrl'] as String?)?.trim().isNotEmpty == true
        ? json['minioUrl'] as String
        : 'http://localhost:9000',
    extras: (json['extras'] as Map?)?.cast<String, dynamic>() ?? const {},
  );

  AppConfig copyWith({
    String? baseUrl,
    String? minioUrl,
    Map<String, dynamic>? extras,
  }) => AppConfig(
    baseUrl: baseUrl ?? this.baseUrl,
    minioUrl: minioUrl ?? this.minioUrl,
    extras: extras ?? this.extras,
  );
}

Future<AppConfig> loadAppConfig(String flavor) async {
  final String assetPath = 'assets/config/${flavor.toLowerCase()}.json';
  try {
    final raw = await rootBundle.loadString(assetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return AppConfig.fromJson(map);
  } catch (_) {
    // 兜底默认配置
    return const AppConfig(
      baseUrl: 'http://localhost:8080',
      minioUrl: 'http://localhost:9000',
    );
  }
}
