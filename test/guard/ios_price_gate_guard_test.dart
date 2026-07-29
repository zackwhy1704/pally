import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// iOS App Store 3.1.1 anti-steering: no subscription PRICE may be shown in-app
/// on iOS without the External Link entitlement. Every price string must be
/// gated behind `allowPriceDisplay(ref)`. This guard fails if a file renders a
/// price-looking string (US$9.99, S$14.90, $19.99/mo) but never references
/// allowPriceDisplay — the "gated every surface except one" leak that shipped in
/// settings_screen. New price surfaces MUST gate; do not extend an allow-list.
///
/// i18n indirection: once a price moves into the ARB, the render site references
/// `l.<key>` instead of the literal, and the literal lives in the generated
/// `lib/l10n/app_localizations_*.dart` string table (which never renders). A pure
/// literal-grep would then (a) go blind at the real render site and (b) false-flag
/// the string table. So this guard ALSO derives the set of "price keys" from the
/// ARB and requires every file that references one to gate it. The string table
/// itself is excluded — it holds prices as data, it does not display them.
void main() {
  // A real currency display: "US$9", "S$14", or a "$" with cents ("$9.99").
  // Deliberately excludes Dart record accessors (.$1/.$2) and math ($6CO_2).
  final pricePattern = RegExp(r'US\$\s?\d|S\$\s?\d|\$\d+\.\d{2}');

  // ARB keys whose VALUE is a price. A localized price is still a price.
  final arb = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
      as Map<String, dynamic>;
  final priceKeys = <String>{
    for (final e in arb.entries)
      if (!e.key.startsWith('@') &&
          e.value is String &&
          pricePattern.hasMatch(e.value as String))
        e.key,
  };

  // The gen-l10n string table (app_localizations.dart + _en/_zh/...): it HOLDS the
  // price strings as data but never renders them. Render sites reference the key
  // and are checked below.
  bool isL10nStringTable(String path) =>
      path.replaceAll(r'\', '/').contains('lib/l10n/');

  test('every file that shows a price also gates it with allowPriceDisplay', () {
    final offenders = <String>[];
    for (final f
        in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.endsWith('.g.dart')) continue;
      if (isL10nStringTable(f.path)) continue;
      final src = f.readAsStringSync();
      final showsLiteralPrice = pricePattern.hasMatch(src);
      final usesPriceKey = priceKeys.any((k) => src.contains('.$k'));
      if ((showsLiteralPrice || usesPriceKey) &&
          !src.contains('allowPriceDisplay')) {
        offenders.add(f.path.replaceFirst('lib/', ''));
      }
    }
    expect(offenders, isEmpty,
        reason: 'These render a price (literal or via a price ARB key) without '
            'an allowPriceDisplay gate (App Store 3.1.1 risk):\n'
            '${offenders.join('\n')}');
  });

  test('the ARB price-key detection is not silently empty', () {
    // If a rename or a broken ARB parse emptied priceKeys, the indirection check
    // above would pass vacuously. Pin the known price key so the guard can never
    // quietly stop protecting localized prices.
    expect(priceKeys, contains('settingsKeepPremiumPrice'),
        reason: 'Expected the localized Keep-Premium price string to be detected '
            'as a price key. If it was renamed, update this guard.');
  });
}
