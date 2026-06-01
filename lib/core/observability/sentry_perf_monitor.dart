import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/noop_observability.dart';
import 'package:pally/core/observability/sentry_observability.dart';

class _SentrySpan implements PerfSpan {
  _SentrySpan(this._span);
  final ISentrySpan _span;

  @override
  void finish({int? statusCode}) {
    _span.status = statusCode != null && statusCode >= 400
        ? const SpanStatus.internalError()
        : const SpanStatus.ok();
    _span.finish();
  }

  @override
  void setTag(String key, String value) => _span.setTag(key, value);

  @override
  void setData(String key, Object? value) => _span.setData(key, value);
}

class SentryPerfMonitor implements PerfMonitor {
  const SentryPerfMonitor();

  /// Use SentryObservability.isActive (resolves embedded DSNs by APP_ENV).
  /// Removed the stale `const _sentryDsn = String.fromEnvironment('SENTRY_DSN')`
  /// gate that would silently no-op even in prod builds with baked-in DSNs.
  static bool get _active => SentryObservability.isActive;

  @override
  PerfSpan startSpan(String name,
      {String? operation, String? description}) {
    if (!_active) return const NoopPerfMonitor().startSpan(name);
    final txn = Sentry.startTransaction(
      name,
      operation ?? 'task',
      description: description,
      bindToScope: false,
    );
    return _SentrySpan(txn);
  }
}
