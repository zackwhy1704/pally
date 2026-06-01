import 'package:pally/core/observability/observability.dart';

/// No-op implementations used in debug builds and unit tests.
/// Zero side effects, zero network calls.

class NoopAnalytics implements Analytics {
  const NoopAnalytics();
  @override void event(String name, {Map<String, Object?> props = const {}}) {}
  @override void screen(String name, {Map<String, Object?> props = const {}}) {}
  @override void identify(String uid, {Map<String, Object?> props = const {}}) {}
  @override void reset() {}
}

class _NoopSpan implements PerfSpan {
  const _NoopSpan();
  @override void finish({int? statusCode}) {}
  @override void setTag(String key, String value) {}
  @override void setData(String key, Object? value) {}
}

class NoopPerfMonitor implements PerfMonitor {
  const NoopPerfMonitor();
  @override
  PerfSpan startSpan(String name,
      {String? operation, String? description}) =>
      const _NoopSpan();
}
