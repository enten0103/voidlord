class AppConfig {
  final String baseUrl;
  final String minioUrl;
  final Map<String, dynamic> extras;

  const AppConfig({
    required this.baseUrl,
    required this.minioUrl,
    this.extras = const {},
  });
}
