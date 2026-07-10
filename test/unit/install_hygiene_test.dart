import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/services/install_hygiene.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('wipeSecureStorageOnFirstLaunch', () {
    test('first launch (marker absent) wipes once and sets the marker',
        () async {
      SharedPreferences.setMockInitialValues({}); // fresh install
      final prefs = await SharedPreferences.getInstance();
      var wipes = 0;

      final wiped = await wipeSecureStorageOnFirstLaunch(
        prefs: prefs,
        wipe: () async => wipes++,
      );

      expect(wiped, isTrue);
      expect(wipes, 1); // secure storage was cleared exactly once

      // The marker must now be set so the NEXT launch is a no-op.
      final wipedAgain = await wipeSecureStorageOnFirstLaunch(
        prefs: prefs,
        wipe: () async => wipes++,
      );
      expect(wipedAgain, isFalse);
      expect(wipes, 1); // no second wipe
    });

    test('normal launch (marker present) does NOT wipe the live session',
        () async {
      SharedPreferences.setMockInitialValues(
          {'secure_storage_install_marker_v1': true});
      final prefs = await SharedPreferences.getInstance();
      var wipes = 0;

      final wiped = await wipeSecureStorageOnFirstLaunch(
        prefs: prefs,
        wipe: () async => wipes++,
      );

      expect(wiped, isFalse);
      expect(wipes, 0); // the existing token/session is left intact
    });

    test('a wipe failure still sets the marker (no loop-wipe) and never throws',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final wiped = await wipeSecureStorageOnFirstLaunch(
        prefs: prefs,
        wipe: () async => throw Exception('keychain unavailable'),
      );

      expect(wiped, isTrue); // reported as first-launch handled
      // Marker set despite the failure → next launch is a no-op, not a re-wipe.
      var secondWipes = 0;
      final again = await wipeSecureStorageOnFirstLaunch(
        prefs: prefs,
        wipe: () async => secondWipes++,
      );
      expect(again, isFalse);
      expect(secondWipes, 0);
    });
  });
}
