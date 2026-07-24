import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/features/voice_input/data/voice_input_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('voice input RUNTIME default (readPersistedVoiceInputEnabled)', () {
    test('no persisted value → OFF (voice ships DARK pending the DPIA/legal review)',
        () async {
      // Fail-without-fix: the default was `?? true`; flipped to `?? false` so a
      // child's voice cannot reach cloud STT by default before legal clears.
      // main.dart applies THIS value as the bootstrap override, so it is the
      // real runtime default (not the test-only synchronous provider default).
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(await readPersistedVoiceInputEnabled(prefs), isFalse);
    });

    test('persisted true → ON (the enable path a future "flip on" release uses)',
        () async {
      SharedPreferences.setMockInitialValues({voiceInputEnabledPrefsKey: true});
      final prefs = await SharedPreferences.getInstance();

      expect(await readPersistedVoiceInputEnabled(prefs), isTrue);
    });
  });
}
