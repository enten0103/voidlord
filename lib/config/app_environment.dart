/// App build-time environment configuration.
///
/// Use `--dart-define` to set values at build/run time. Example:
/// flutter run --dart-define=FLAVOR=prod --dart-define=BACKEND_BASE_URL=https://api.example.com
class AppEnvironment {
  /// dev | test | prod ...
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  /// Base URL for backend API
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// Optional DSN or other keys
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static bool get isDev => flavor.toLowerCase() == 'dev';
  static bool get isTest => flavor.toLowerCase() == 'test';
  static bool get isProd => flavor.toLowerCase() == 'prod';
}
