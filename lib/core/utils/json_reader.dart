import 'package:pally/core/utils/logger.dart';

/// Thrown when a network-sourced JSON map is missing a field the UI
/// treats as load-bearing, or that field is the wrong type. Per CLAUDE.md
/// PART 16: a broken backend contract must surface as a real error, never
/// be masked behind a silent default (`?? 0` / `?? ''`) that shows a
/// parent fake zeros.
class JsonParseException implements Exception {
  const JsonParseException(this.key, this.reason);

  /// The JSON key that was required but absent or wrong-typed.
  final String key;

  /// Human-readable reason (e.g. "missing", "expected int, got String").
  final String reason;

  @override
  String toString() => 'JsonParseException(key=$key, reason=$reason)';
}

/// A thin, typed reader over a decoded JSON map. Use `require<T>` for
/// fields the screen genuinely depends on (a missing one means the
/// backend contract is broken and the user should see an error, not
/// silent zeros). Use `optional<T>` only when a field is legitimately
/// absent for some shapes — always with an explicit default + a comment
/// explaining why it's allowed to be missing.
extension JsonReader on Map<String, dynamic> {
  /// Reads [key] as [T], coercing numeric types (num→int/double).
  /// Throws [JsonParseException] if the key is missing or not coercible.
  T require<T>(String key) {
    if (!containsKey(key) || this[key] == null) {
      appLog.e('[Json] required field "$key" missing in $keys');
      throw JsonParseException(key, 'missing');
    }
    final value = this[key];
    final coerced = _coerce<T>(value);
    if (coerced == null) {
      appLog.e('[Json] field "$key" is ${value.runtimeType}, '
          'expected $T');
      throw JsonParseException(
          key, 'expected $T, got ${value.runtimeType}');
    }
    return coerced;
  }

  /// Reads [key] as [T], returning [fallback] when the key is absent or
  /// null. Only use for fields that are legitimately optional across
  /// backend response shapes — never to paper over a broken contract.
  T optional<T>(String key, T fallback) {
    if (!containsKey(key) || this[key] == null) return fallback;
    final coerced = _coerce<T>(this[key]);
    return coerced ?? fallback;
  }

  static T? _coerce<T>(Object? value) {
    if (value is T) return value;
    if (value is num) {
      if (T == int) return value.toInt() as T;
      if (T == double) return value.toDouble() as T;
    }
    return null;
  }
}
