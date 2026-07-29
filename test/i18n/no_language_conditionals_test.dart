import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/i18n/app_languages.dart';

/// B-EXT.2 — NO LANGUAGE CONDITIONALS IN UI CODE.
///
/// The client treats the language set as DATA, not branches. A widget must never
/// hardcode a non-English language code: `if (locale == 'zh')`, `code == 'zh' ? …`,
/// `Locale('zh')`, etc. All language-varying text lives in ARB; anything that
/// genuinely can't (a font, a line-height) belongs as a FIELD on the registry
/// entry, not a conditional at the call site.
///
/// This guard scans lib/features (the widget layer) for any registry language
/// code OTHER than the English fallback appearing as a quoted literal. It is
/// language-agnostic: the forbidden set is derived from [AppLanguages], so when
/// Malay is added the guard covers 'ms' automatically. Keeping this green is how
/// "add a language = one registry entry + one ARB file" stays true.
void main() {
  test('no widget file in lib/features hardcodes a non-English language code',
      () {
    // Every registry code except the English fallback. These must never appear
    // as string literals in widget code.
    final forbidden = [
      for (final l in AppLanguages.all)
        if (l.code != AppLanguages.fallback.code) l.code,
    ];
    expect(forbidden, isNotEmpty,
        reason: 'sanity: the registry has at least one non-English language');

    final featuresDir = Directory('lib/features');
    expect(featuresDir.existsSync(), isTrue);

    final offenders = <String>[];
    for (final entity in featuresDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final code in forbidden) {
        if (source.contains("'$code'") || source.contains('"$code"')) {
          offenders.add('${entity.path} contains a hardcoded "$code" literal');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Language-varying behaviour must be DATA (ARB string or a field on '
          'the AppLanguages registry entry), never a per-language branch in a '
          'widget. Offenders:\n${offenders.join('\n')}',
    );
  });
}
