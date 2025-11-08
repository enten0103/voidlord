import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AppConfig {
  final String baseUrl;
  final Map<String, dynamic> extras;

  const AppConfig({
    required this.baseUrl,
    this.extras = const {},
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
        baseUrl: (json['baseUrl'] as String?)?.trim().isNotEmpty == true
            ? json['baseUrl'] as String
            : 'http://localhost:8080',
        extras: (json['extras'] as Map?)?.cast<String, dynamic>() ?? const {},
      );

  AppConfig copyWith({String? baseUrl, Map<String, dynamic>? extras}) => AppConfig(
        baseUrl: baseUrl ?? this.baseUrl,
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
    return const AppConfig(baseUrl: 'http://localhost:8080');
  }
}
