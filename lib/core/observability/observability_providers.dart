import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/noop_observability.dart';
import 'package:pally/core/observability/sentry_perf_monitor.dart';
import 'package:pally/core/observability/sentry_observability.dart';
import 'package:pally/core/observability/posthog_analytics.dart';

/// Active in release when APP_ENV=production|development (DSN is now embedded
/// in sentry_observability.dart; the stale SENTRY_DSN env-var gate is gone).
final perfMonitorProvider = Provider<PerfMonitor>((_) {
  return SentryObservability.isActive
      ? const SentryPerfMonitor()
      : const NoopPerfMonitor();
});

/// PostHog analytics in release builds; NoopAnalytics in debug to avoid
/// polluting dashboards during development.
final analyticsProvider = Provider<Analytics>((_) {
  return SentryObservability.isActive
      ? const PostHogAnalytics()
      : const NoopAnalytics();
});
