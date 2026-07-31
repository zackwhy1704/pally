import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// zh audit round 5: `homeSectionYourMochis` was translated as `"你的 Mochi"`
/// — the raw English word typed literally instead of the established
/// `{mascot}` placeholder (or, for the handful of keys with no placeholder
/// mechanism, the literal 小伴). This is a DISTINCT failure mode from
/// everything the l10n coverage guard already catches: not a missing key, not
/// a wrong data source, not a stale cache — a single ARB VALUE that silently
/// leaked the untranslated brand name past three prior localization rounds,
/// because nothing was diffing ARB values against a "contains untranslated
/// brand name" rule. This guard closes that gap permanently.
///
/// Scans VALUES only (never key names — `mochiTip1`, `homeMochiLocked` etc.
/// are correct key names whose VALUES don't leak "Mochi"), so a key merely
/// mentioning "mochi" in its own name never false-positives here.
void main() {
  test('no app_zh.arb value contains the raw untranslated word "Mochi"', () {
    final raw = File('lib/l10n/app_zh.arb').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final leaks = <String>[];
    for (final entry in json.entries) {
      if (entry.key.startsWith('@')) continue; // ARB metadata, not a value
      final value = entry.value;
      if (value is String && value.contains('Mochi')) {
        leaks.add('${entry.key}: "$value"');
      }
    }

    expect(leaks, isEmpty,
        reason: 'zh strings must use {mascot} (or, where no placeholder '
            'exists, the established 小伴 word) — never the literal English '
            'brand name. Found:\n${leaks.join('\n')}');
  });
}
