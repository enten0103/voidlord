import 'package:flutter_test/flutter_test.dart';
import 'package:voidlord/config/app_environment.dart';

void main() {
  test('AppEnvironment has sensible defaults', () {
    expect(AppEnvironment.flavor, isNotEmpty);
    expect(AppEnvironment.baseUrl, isNotEmpty);
    // Defaults when not provided via --dart-define
    expect(AppEnvironment.flavor, anyOf(['dev', 'test', 'prod', isA<String>()]));
    expect(AppEnvironment.baseUrl, startsWith('http'));
  });
}
