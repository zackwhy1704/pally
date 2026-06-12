import 'package:dio/dio.dart';
import 'package:pally/core/utils/json_reader.dart';

/// Buckets every failure into one of seven kinds so the UI can choose
/// the right copy + recovery affordance without sprinkling DioException
/// type-switches across view models.
///
/// The `userMessage` is intentionally warm + blameless ("Mochi's having
/// trouble" not "500 Internal Server Error"). Raw `toString()` from a
/// thrown exception must never reach a widget — go through this mapper.
enum PallyErrorKind {
  offline,
  timeout,
  server,
  notFound,
  unauthorized,
  upgradeRequired,
  slotLocked,
  aiBusy,
  unknown,
}

class PallyError {
  const PallyError(this.kind, this.userMessage);

  final PallyErrorKind kind;
  final String userMessage;

  static const offline = PallyError(
      PallyErrorKind.offline,
      "You're offline — check your WiFi and try again.");
  static const timeout = PallyError(
      PallyErrorKind.timeout,
      "Mochi's taking a while to respond. Try again in a moment.");
  static const server = PallyError(
      PallyErrorKind.server,
      "Mochi's having trouble right now. Please try again.");
  static const notFound = PallyError(
      PallyErrorKind.notFound, 'Nothing here yet.');
  static const unauthorized = PallyError(
      PallyErrorKind.unauthorized, 'Please sign in again.');
  static const upgradeRequired = PallyError(
      PallyErrorKind.upgradeRequired,
      'This needs Apalchi Premium.');
  static const slotLocked = PallyError(
      PallyErrorKind.slotLocked,
      'This Mochi is locked — activate a slot to use it.');
  static const aiBusy = PallyError(
      PallyErrorKind.aiBusy,
      'Mochi is busy right now — try again in a moment.');
  static const compileTimeout = PallyError(
      PallyErrorKind.timeout,
      'Mochi is still working on your notes in the background '
      '— check back in a few minutes.');
  static const unknown = PallyError(
      PallyErrorKind.unknown,
      'Something went wrong. Please try again.');
  static const badContract = PallyError(
      PallyErrorKind.server,
      "Mochi got an unexpected reply — some info couldn't load. "
      'Please try again.');

  /// Best-effort mapping from any thrown object to a user-safe message.
  /// Never reflects `toString()` directly — every branch lands on a
  /// curated string above.
  static PallyError from(Object e) {
    if (e is PallyError) return e;
    if (e is DioException) return _fromDio(e);
    if (e is JsonParseException) return badContract;
    return unknown;
  }

  static PallyError _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return offline;
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return timeout;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 404) return notFound;
        if (code == 401) return unauthorized;
        if (code == 402) return upgradeRequired;
        if (code == 409) return slotLocked;
        if (code == 503) return aiBusy;
        if (code == 504) return compileTimeout;
        final backend = _safeBackendMessage(e.response?.data);
        if (backend != null) return PallyError(PallyErrorKind.server, backend);
        return server;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return unknown;
    }
  }

  /// Backend error messages flow through ApiResponse as
  /// {data, error|message, status}. Only adopt the backend's string when
  /// it's short, kid-safe, and clearly not a raw stack — anything that
  /// smells like an internal exception falls back to a curated message.
  static String? _safeBackendMessage(dynamic data) {
    if (data is! Map) return null;
    final raw = data['error'] ?? data['message'];
    if (raw is! String) return null;
    final s = raw.trim();
    if (s.isEmpty || s.length > 140) return null;
    if (s.contains('Exception')) return null;
    if (s.contains('NullPointer')) return null;
    if (s.startsWith('java.')) return null;
    return s;
  }
}
