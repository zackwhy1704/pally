import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// SNACKBAR SAFETY GUARD (the mechanical invariant behind the root-messenger fix).
///
/// Every snackbar must be shown through the app-root ScaffoldMessenger —
/// `showAppSnackBar(...)` / `rootScaffoldMessengerKey` in core/ui/pally_toast.dart —
/// NEVER `ScaffoldMessenger.of(context)`. A context-bound show binds to the caller's
/// widget, which throws "Looking up a deactivated widget's ancestor is unsafe" when
/// the screen disposes while the snackbar is still animating (the exact FlutterError
/// this fix targets). Routing through the key is context-free and survives disposal.
///
/// This is the guard that makes the fix un-half-doable: a root key that exists but
/// that individual `ScaffoldMessenger.of(context)` calls bypass is the half-fix — so
/// assert ZERO `ScaffoldMessenger.of(` in all of lib/ (pally_toast itself uses the
/// key, not of(), so it is not exempt). A new snackbar added via of(context) fails CI.
void main() {
  test('no ScaffoldMessenger.of(context) in lib/ — every snackbar routes through the root key', () {
    final offenders = <String>[];
    var scanned = 0;
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        scanned++;
        for (final line in entity.readAsStringSync().split('\n')) {
          final trimmed = line.trimLeft();
          // Skip comment lines (the helper's own docs mention the banned call by name).
          if (trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('/*')) {
            continue;
          }
          if (line.contains('ScaffoldMessenger.of(')) {
            offenders.add('${entity.path}: ${line.trim()}');
          }
        }
      }
    }
    // VACUOUS-PASS FLOOR. This guard asserts ZERO matches, which is exactly the
    // result an empty scan produces. Without this, a filter that stopped
    // matching .dart files would report a clean codebase forever. ~390 .dart
    // files under lib/ today (generated ones included, since this scan reads
    // them too).
    expect(scanned, greaterThan(250),
        reason: 'Snackbar scan read only $scanned files — it is not scanning '
            'lib/, so "zero offenders" is meaningless.');
    expect(
      offenders,
      isEmpty,
      reason: 'Show snackbars via showAppSnackBar(...) (core/ui/pally_toast.dart), not '
          'ScaffoldMessenger.of(context) — these files still bind to a screen context '
          'that can be disposed mid-snackbar:\n${offenders.join('\n')}',
    );
  });
}
