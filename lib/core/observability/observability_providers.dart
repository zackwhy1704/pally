import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/noop_observability.dart';
import 'package:pally/core/observability/sentry_perf_monitor.dart';
import 'package:pally/core/observability/sentry_observability.dart';

const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

/// Active in release when DSN is set; noop otherwise.
final perfMonitorProvider = Provider<PerfMonitor>((_) {
  if (_sentryDsn.isNotEmpty && kReleaseMode) {
    return const SentryPerfMonitor();
  }
  return const NoopPerfMonitor();
});

/// Phase 6: swap [NoopAnalytics] for PostHog / Firebase implementation.
/// Until then: zero network calls, zero PII risk.
final analyticsProvider = Provider<Analytics>((_) {
  if (_sentryDsn.isNotEmpty && kReleaseMode) {
    return const SentryAnalytics();
  }
  return const NoopAnalytics();
});
