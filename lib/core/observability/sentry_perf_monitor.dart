import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/noop_observability.dart';

const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

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

  static bool get _active => _sentryDsn.isNotEmpty && kReleaseMode;

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
