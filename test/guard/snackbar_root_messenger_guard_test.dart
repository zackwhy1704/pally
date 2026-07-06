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
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
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
    expect(
      offenders,
      isEmpty,
      reason: 'Show snackbars via showAppSnackBar(...) (core/ui/pally_toast.dart), not '
          'ScaffoldMessenger.of(context) — these files still bind to a screen context '
          'that can be disposed mid-snackbar:\n${offenders.join('\n')}',
    );
  });
}
