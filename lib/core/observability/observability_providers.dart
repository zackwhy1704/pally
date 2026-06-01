import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/noop_observability.dart';
import 'package:pally/core/observability/sentry_perf_monitor.dart';
import 'package:pally/core/observability/sentry_observability.dart';

/// Active in release when APP_ENV=production|development (DSN is now embedded
/// in sentry_observability.dart; the stale SENTRY_DSN env-var gate is gone).
final perfMonitorProvider = Provider<PerfMonitor>((_) {
  return SentryObservability.isActive
      ? const SentryPerfMonitor()
      : const NoopPerfMonitor();
});

/// Phase 6: swap [NoopAnalytics] for PostHog / Firebase implementation.
/// Until then: zero network calls, zero PII risk.
final analyticsProvider = Provider<Analytics>((_) {
  return SentryObservability.isActive
      ? const SentryAnalytics()
      : const NoopAnalytics();
});
