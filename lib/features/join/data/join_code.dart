/// What a join code points at. `unknown` = a bare code typed by hand or read off
/// a card, whose real type is resolved server-side via `resolve-code`.
enum JoinKind { classroom, group, parentClaim, unknown }

/// A parsed join code. QR payloads are self-describing — `APX:TYPE:CODE`
/// (e.g. `APX:CLASS:5K7Q2X`) — so a scan routes by type with NO network
/// round-trip. Plain codes (manual entry) parse as [JoinKind.unknown] with the
/// cleaned code and are named server-side before any join.
class JoinCode {
  const JoinCode(this.kind, this.code);

  final JoinKind kind;
  final String code;

  static const String prefix = 'APX';

  /// Parse a scanned/typed string. Never throws; returns null only for an empty
  /// or malformed-`APX` input. A non-prefixed string is treated as a bare code.
  static JoinCode? parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final upper = trimmed.toUpperCase();

    if (upper.startsWith('$prefix:')) {
      final parts = upper.split(':');
      // APX:TYPE:CODE — extra segments (e.g. a future name) are ignored.
      if (parts.length < 3) return null;
      final code = parts[2].trim();
      if (code.isEmpty) return null;
      return JoinCode(_kindFrom(parts[1].trim()), code);
    }

    // Bare code: strip whitespace, keep it uppercase.
    final code = upper.replaceAll(RegExp(r'\s+'), '');
    if (code.isEmpty) return null;
    return JoinCode(JoinKind.unknown, code);
  }

  static JoinKind _kindFrom(String type) {
    switch (type) {
      case 'CLASS':
        return JoinKind.classroom;
      case 'GROUP':
        return JoinKind.group;
      case 'PARENTCLAIM':
        return JoinKind.parentClaim;
      default:
        return JoinKind.unknown;
    }
  }
}
