import 'package:budgets/core/monitoring/sentry_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SentryConfig', () {
    test('is disabled when the DSN is blank', () {
      final config = SentryConfig.fromValues(
        dsn: '  ',
        environment: '',
        isRelease: false,
      );

      expect(config.isEnabled, isFalse);
    });

    test('normalizes supplied values', () {
      final config = SentryConfig.fromValues(
        dsn: ' https://public@sentry.example/1 ',
        environment: ' staging ',
        isRelease: false,
      );

      expect(config.dsn, 'https://public@sentry.example/1');
      expect(config.environment, 'staging');
      expect(config.isEnabled, isTrue);
      expect(config.startupTestEnabled, isFalse);
    });

    test('uses production as the release environment fallback', () {
      final config = SentryConfig.fromValues(
        dsn: 'dsn',
        environment: '',
        isRelease: true,
      );

      expect(config.environment, 'production');
    });

    test('uses development as the debug environment fallback', () {
      final config = SentryConfig.fromValues(
        dsn: 'dsn',
        environment: '',
        isRelease: false,
      );

      expect(config.environment, 'development');
    });

    test('enables the explicit startup check', () {
      final config = SentryConfig.fromValues(
        dsn: 'dsn',
        environment: 'development',
        isRelease: false,
        startupTestEnabled: true,
      );

      expect(config.startupTestEnabled, isTrue);
    });
  });
}
