import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// iOS App Store 3.1.1 anti-steering: no subscription PRICE may be shown in-app
/// on iOS without the External Link entitlement. Every price string must be
/// gated behind `allowPriceDisplay(ref)`. This guard fails if a file renders a
/// price-looking string (US$9.99, S$14.90, $19.99/mo) but never references
/// allowPriceDisplay — the "gated every surface except one" leak that shipped in
/// settings_screen. New price surfaces MUST gate; do not extend an allow-list.
void main() {
    // A real currency display: "US$9", "S$14", or a "$" with cents ("$9.99").
    // Deliberately excludes Dart record accessors (.$1/.$2) and math ($6CO_2).
    final pricePattern = RegExp(r'US\$\s?\d|S\$\s?\d|\$\d+\.\d{2}');

  test('every file that shows a price also gates it with allowPriceDisplay', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.endsWith('.g.dart')) continue;
      final src = f.readAsStringSync();
      if (!pricePattern.hasMatch(src)) continue;
      if (!src.contains('allowPriceDisplay')) {
        offenders.add(f.path.replaceFirst('lib/', ''));
      }
    }
    expect(offenders, isEmpty,
        reason: 'These render a price without an allowPriceDisplay gate '
            '(App Store 3.1.1 risk):\n${offenders.join('\n')}');
  });
}
