import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/error/pally_error.dart';

/// Pins PallyError.forCompile — the CENTRAL per-cause mapping for the chapter
/// compile flow (the widget must never inspect DioException itself; the layering
/// guard enforces that). A client timeout on a compile does NOT mean the server
/// failed (compile runs async), so it points to Library and stays retryable.
DioException _dio(DioExceptionType type, {int? status}) {
  final ro = RequestOptions(path: '/compile');
  return DioException(
    requestOptions: ro,
    type: type,
    response: status == null ? null : Response(requestOptions: ro, statusCode: status),
  );
}

void main() {
  test('receive/send timeout → Library-pointing compileTimeout, not a failure', () {
    for (final t in [DioExceptionType.receiveTimeout, DioExceptionType.sendTimeout]) {
      final err = PallyError.forCompile(_dio(t));
      expect(err.kind, PallyErrorKind.timeout);
      expect(err.userMessage, contains('check Library'));
    }
  });

  test('connection error/timeout → offline (check WiFi)', () {
    for (final t in [DioExceptionType.connectionError, DioExceptionType.connectionTimeout]) {
      final err = PallyError.forCompile(_dio(t));
      expect(err.kind, PallyErrorKind.offline);
    }
  });

  test('409 → friendly already-running note (not the generic slot-lock copy)', () {
    final err = PallyError.forCompile(_dio(DioExceptionType.badResponse, status: 409));
    expect(err, same(PallyError.compileInProgress));
    expect(err.userMessage, contains('already reading'));
  });

  test('any 5xx → blameless server copy', () {
    for (final code in [500, 502, 503, 504]) {
      final err = PallyError.forCompile(_dio(DioExceptionType.badResponse, status: code));
      expect(err.kind, PallyErrorKind.server);
    }
  });

  test('402/403 still defer to the central mapper (upgrade / consent unchanged)', () {
    expect(PallyError.forCompile(_dio(DioExceptionType.badResponse, status: 402)).kind,
        PallyErrorKind.upgradeRequired);
    expect(PallyError.forCompile(_dio(DioExceptionType.badResponse, status: 403)).kind,
        PallyErrorKind.permissionDenied);
  });

  test('an already-mapped PallyError passes through untouched', () {
    expect(PallyError.forCompile(PallyError.consentRequired), same(PallyError.consentRequired));
  });
}
