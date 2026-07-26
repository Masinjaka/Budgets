import 'dart:async';

import 'package:budgets/core/monitoring/sentry_config.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef ApplicationRunner = FutureOr<void> Function();

class SentryBootstrap {
  const SentryBootstrap._();

  static Future<void> run(ApplicationRunner appRunner) async {
    const dsn = String.fromEnvironment('SENTRY_DSN');
    const environment = String.fromEnvironment('SENTRY_ENVIRONMENT');
    const startupTestEnabled = bool.fromEnvironment('SENTRY_STARTUP_TEST');
    final config = SentryConfig.fromValues(
      dsn: dsn,
      environment: environment,
      isRelease: kReleaseMode,
      startupTestEnabled: startupTestEnabled,
    );

    if (!config.isEnabled) {
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options
          ..dsn = config.dsn
          ..environment = config.environment
          ..sendDefaultPii = false
          ..attachScreenshot = false
          ..attachViewHierarchy = false
          ..maxRequestBodySize = MaxRequestBodySize.never;
      },
      appRunner: () async {
        if (config.startupTestEnabled) {
          await Sentry.captureMessage(
            'Drala Sentry startup test',
            level: SentryLevel.warning,
          );
        }
        await appRunner();
      },
    );
  }
}
