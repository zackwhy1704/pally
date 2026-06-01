import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/core/observability/noop_observability.dart';

/// DSN supplied via `--dart-define=SENTRY_DSN=https://...`
/// If not present (debug / no-DSN) the app runs without Sentry.
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

class SentryObservability {
  /// Wraps [appRunner] in Sentry + runZonedGuarded.
  /// In debug or when DSN is absent: runs appRunner directly.
  static Future<void> run(Future<void> Function() appRunner) async {
    final active = _sentryDsn.isNotEmpty && kReleaseMode;

    if (!active) {
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = _sentryDsn;
        options.tracesSampleRate = 0.2;
        options.profilesSampleRate = 0.1;
        options.environment =
            kReleaseMode ? 'production' : 'development';
        options.attachScreenshot = false; // PDPA — never capture screenshots
        options.sendDefaultPii = false;   // PDPA — no PII
        options.debug = false;
      },
      appRunner: appRunner,
    );
  }

  /// Forward a Flutter framework error to Sentry + appLog.
  static void reportFlutterError(FlutterErrorDetails details) {
    FlutterError.presentError(details);
    appLog.e(
      '[FlutterError] ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (_sentryDsn.isNotEmpty && kReleaseMode) {
      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
        hint: Hint.withMap({'context': 'FlutterError'}),
      );
    }
  }

  /// Forward a platform/async error to Sentry + appLog.
  static bool reportError(Object error, StackTrace stack) {
    appLog.e('[PlatformError] $error', error: error, stackTrace: stack);
    if (_sentryDsn.isNotEmpty && kReleaseMode) {
      Sentry.captureException(error, stackTrace: stack);
    }
    return true;
  }
}

/// Sentry-backed analytics (Phase 6: swap for PostHog).
/// Currently a no-op; wired via [analyticsProvider].
class SentryAnalytics extends NoopAnalytics {
  const SentryAnalytics();
}
