import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/core/observability/noop_observability.dart';

/// Environment selector, supplied at build time:
///   --dart-define=APP_ENV=production   (or `development`, the default)
/// This drives BOTH which DSN is used and how events are tagged in Sentry.
const _appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');

/// Optional override DSN. If supplied via --dart-define=SENTRY_DSN=..., it wins
/// over the built-in prod/dev defaults below (useful for staging or testing).
const _dsnOverride = String.fromEnvironment('SENTRY_DSN');

/// Built-in project DSNs (DSNs are embeddable identifiers, not secrets). The
/// active one is chosen by [_appEnv]; an explicit SENTRY_DSN override beats both.
const _prodDsn =
    'https://efeab9256afdc04a71026d7fc835e664@o4511490655191040.ingest.us.sentry.io/4511490671181824';
const _devDsn =
    'https://ea84ae120f4b757dbcc34574ca10655a@o4511490655191040.ingest.us.sentry.io/4511490699100160';

bool get _isProd => _appEnv == 'production' || _appEnv == 'prod';

/// Resolved DSN for this build: explicit override → prod (if APP_ENV=production)
/// → dev otherwise.
String get _sentryDsn {
  if (_dsnOverride.isNotEmpty) return _dsnOverride;
  return _isProd ? _prodDsn : _devDsn;
}

class SentryObservability {
  /// Whether Sentry should actually send events.
  ///
  /// Active only in release builds with a non-empty DSN. Debug builds never
  /// send — so day-to-day local development stays silent and doesn't burn the
  /// free-tier quota. To exercise Sentry locally, build in profile/release with
  /// `--dart-define=APP_ENV=development`.
  static bool get isActive => _sentryDsn.isNotEmpty && kReleaseMode;

  /// Wraps [appRunner] in Sentry + runZonedGuarded.
  /// In debug or when inactive: runs appRunner directly.
  static Future<void> run(Future<void> Function() appRunner) async {
    if (!isActive) {
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = _sentryDsn;
        // Performance tracing. Keep sampling modest to protect the free-tier
        // span quota (~10k/mo); raise once you have traffic worth tracing.
        options.tracesSampleRate = 0.2;
        options.profilesSampleRate = 0.1;
        // Tag every event with the real environment so prod/dev are separable
        // in the dashboard (and feed different DSNs/projects anyway).
        options.environment = _isProd ? 'production' : 'development';
        options.attachScreenshot = false; // PDPA — never capture screenshots
        options.sendDefaultPii = false; // PDPA — no PII (IP, etc.)
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
    if (isActive) {
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
    if (isActive) {
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
