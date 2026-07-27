import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/features/voice_input/data/voice_input_prefs.dart';

void main() {
  group('voiceEnabledFromFlags — server flag → mic, fail-closed', () {
    test('voice_input == true → enabled', () {
      expect(voiceEnabledFromFlags({'voice_input': true}), isTrue);
    });

    test('flag absent → OFF (fail-closed)', () {
      // Fail-without-fix: pins the exact flag key and the fail-closed default. A typo
      // in the key or a truthy-on-absent mapping would let the mic light up without the
      // server saying so — the child-data path must never default on.
      expect(voiceEnabledFromFlags({}), isFalse);
    });

    test('null flags (not yet loaded / fetch failed) → OFF', () {
      expect(voiceEnabledFromFlags(null), isFalse);
    });

    test('voice_input == false → OFF', () {
      expect(voiceEnabledFromFlags({'voice_input': false}), isFalse);
    });
  });

  group('voiceInputEnabledProvider default', () {
    test('defaults OFF (fail-closed) until the app-root sync sets it from the server', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(voiceInputEnabledProvider), isFalse);
    });
  });
}
