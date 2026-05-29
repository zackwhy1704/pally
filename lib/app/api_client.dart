import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

/// Set by `main.dart` so Dio interceptors can reach a `BuildContext` for
/// global toasts (e.g. unhandled 5xx errors). Defaults to no-op if not
/// overridden, so unit tests still work.
final globalNavigatorKeyProvider =
    Provider<GlobalKey<NavigatorState>?>((ref) => null);

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://pallybackend-production.up.railway.app',
);

@riverpod
Dio dio(Ref ref) {
  final auth = ref.watch(authStateProvider);
  final token = auth.token;

  final client = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (auth.userId != null) 'X-User-Id': auth.userId!,
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    ),
  );

  client.interceptors.addAll([
    _PallyLoggingInterceptor(),
    _ServerErrorInterceptor(ref),
    _ApiResponseInterceptor(),
    _SessionExpiredInterceptor(),
  ]);

  return client;
}

// ── Logging interceptor — logs every request, response, and failure ──────────
class _PallyLoggingInterceptor extends Interceptor {
  static const _tag = 'PallyAPI';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    appLog.i(
      '[$_tag] ──► ${options.method} ${options.baseUrl}${options.path}\n'
      '  Headers: ${_sanitiseHeaders(options.headers)}\n'
      '  Body   : ${_truncate(options.data?.toString())}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    appLog.i(
      '[$_tag] ◄── ${response.statusCode} ${response.statusMessage}'
      ' ${response.requestOptions.method} ${response.requestOptions.path}\n'
      '  Body: ${_truncate(response.data?.toString())}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final req = err.requestOptions;
    final reason = _describeError(err);

    appLog.e(
      '[$_tag] ✗✗✗ FAILURE ${req.method} ${req.path}\n  $reason',
      error: err.error,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }

  String _describeError(DioException err) {
    final req = err.requestOptions;
    return switch (err.type) {
      DioExceptionType.connectionTimeout =>
        'CONNECTION TIMEOUT — backend unreachable or too slow\n'
        '  Tried  : ${req.baseUrl}${req.path}\n'
        '  Timeout: ${req.connectTimeout?.inSeconds}s\n'
        '  Fix    : Is backend running? Correct host:port?',
      DioExceptionType.receiveTimeout =>
        'RECEIVE TIMEOUT — backend connected but response too slow\n'
        '  URL    : ${req.baseUrl}${req.path}\n'
        '  Timeout: ${req.receiveTimeout?.inSeconds}s\n'
        '  Fix    : Check for slow DB queries or Claude API latency',
      DioExceptionType.sendTimeout =>
        'SEND TIMEOUT — request body took too long to upload\n'
        '  URL    : ${req.baseUrl}${req.path}',
      DioExceptionType.connectionError =>
        'CONNECTION ERROR — network unreachable or backend down\n'
        '  URL    : ${req.baseUrl}${req.path}\n'
        '  Error  : ${err.error}\n'
        '  Fix    : Is backend running? Correct IP/port? Emulator vs device?',
      DioExceptionType.badResponse =>
        'BAD RESPONSE — server returned HTTP error\n'
        '  Status : ${err.response?.statusCode} ${err.response?.statusMessage}\n'
        '  URL    : ${req.baseUrl}${req.path}\n'
        '  Body   : ${_truncate(err.response?.data?.toString())}',
      DioExceptionType.cancel => 'REQUEST CANCELLED\n  URL: ${req.baseUrl}${req.path}',
      DioExceptionType.badCertificate =>
        'BAD SSL CERTIFICATE\n'
        '  URL: ${req.baseUrl}${req.path}\n'
        '  Fix: Use HTTP for local dev',
      DioExceptionType.unknown =>
        'UNKNOWN ERROR\n'
        '  URL    : ${req.baseUrl}${req.path}\n'
        '  Error  : ${err.error}\n'
        '  Message: ${err.message}',
    };
  }

  Map<String, dynamic> _sanitiseHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    if (copy.containsKey('Authorization')) copy['Authorization'] = 'Bearer [REDACTED]';
    if (copy.containsKey('x-api-key')) copy['x-api-key'] = '[REDACTED]';
    return copy;
  }

  String _truncate(String? s, {int max = 500}) {
    if (s == null) return 'null';
    return s.length > max ? '${s.substring(0, max)}... [+${s.length - max} chars]' : s;
  }
}

// ── Unwraps the Spring Boot ApiResponse<T> envelope ──────────────────────────
class _ApiResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      response.data = body['data'];
    }
    handler.next(response);
  }
}

/// Shows a toast for any 5xx error that individual view-models don't handle.
/// Users see "something is wrong" instead of a silent blank screen — much
/// better than failing silently while the UI keeps spinning.
///
/// Suppressed for auth endpoints so we don't double-toast on the dedicated
/// sign-in error screen, and rate-limited to one toast per 3 seconds to
/// avoid spam from a refresh storm.
class _ServerErrorInterceptor extends Interceptor {
  _ServerErrorInterceptor(this._ref);
  final Ref _ref;
  static DateTime? _lastShown;
  static DateTime? _lastPaywallRoute;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;

    // 402 UPGRADE_REQUIRED → route to /paywall once per second to avoid
    // a refresh loop stacking N paywalls on top of each other.
    if (status == 402) {
      final body = err.response?.data;
      String? code;
      String? feature;
      if (body is Map) {
        final dataNode = body['data'];
        if (dataNode is Map) {
          code = dataNode['code']?.toString();
          feature = dataNode['feature']?.toString();
        }
      }
      if (code == 'UPGRADE_REQUIRED') {
        final now = DateTime.now();
        final allowed = _lastPaywallRoute == null ||
            now.difference(_lastPaywallRoute!) > const Duration(seconds: 1);
        if (allowed) {
          _lastPaywallRoute = now;
          final ctx = _ref.read(globalNavigatorKeyProvider)?.currentContext;
          if (ctx != null && ctx.mounted) {
            // Use go_router string nav so this file doesn't depend on the
            // generated typed-route classes.
            final qs = feature == null || feature.isEmpty
                ? ''
                : '?feature=$feature';
            try {
              ctx.go('/paywall$qs');
            } catch (_) {
              // Fall through; the view model will surface the error.
            }
          }
        }
      }
    }

    if (status != null &&
        status >= 500 &&
        !path.contains('/auth/')) {
      final now = DateTime.now();
      if (_lastShown == null ||
          now.difference(_lastShown!) > const Duration(seconds: 3)) {
        _lastShown = now;
        final ctx = _ref.read(globalNavigatorKeyProvider)?.currentContext;
        if (ctx != null && ctx.mounted) {
          PallyToast.error(
              ctx, 'Server error ($status) — please try again');
        }
      }
    }
    handler.next(err);
  }
}

class _SessionExpiredInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/')) {
      AuthNotifier.instance.signOut();
    }
    handler.next(err);
  }
}
