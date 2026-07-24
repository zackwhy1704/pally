import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/voice_input/domain/speech_recognizer.dart';

/// Locale-selection contract: at runtime pick en-SG if the platform offers
/// it, else en-US, else en-GB, else the platform default — NEVER a hardcoded
/// locale the device might not actually support. Pure function, no plugin
/// involved, so these are fast + deterministic.
void main() {
  group('pickPreferredLocale', () {
    test('prefers en_SG when the platform offers it', () {
      final result = pickPreferredLocale(const [
        SpeechLocale('en_US', 'English (US)'),
        SpeechLocale('en_SG', 'English (Singapore)'),
        SpeechLocale('en_GB', 'English (UK)'),
      ]);
      expect(result, 'en_SG');
    });

    test('falls back to en_US when en_SG is not offered', () {
      final result = pickPreferredLocale(const [
        SpeechLocale('en_GB', 'English (UK)'),
        SpeechLocale('en_US', 'English (US)'),
      ]);
      expect(result, 'en_US');
    });

    test('falls back to en_GB when neither en_SG nor en_US is offered', () {
      final result = pickPreferredLocale(const [
        SpeechLocale('en_GB', 'English (UK)'),
        SpeechLocale('fr_FR', 'French'),
      ]);
      expect(result, 'en_GB');
    });

    test(
        'returns null (platform default) when none of the three are offered — '
        'never hardcodes a locale that might not exist on this device', () {
      final result = pickPreferredLocale(const [
        SpeechLocale('fr_FR', 'French'),
        SpeechLocale('zh_CN', 'Chinese'),
      ]);
      expect(result, isNull);
    });

    test('returns null on an empty locale list', () {
      expect(pickPreferredLocale(const []), isNull);
    });

    test('locale id matching is case-insensitive', () {
      final result = pickPreferredLocale(const [
        SpeechLocale('EN_sg', 'English (Singapore)'),
      ]);
      expect(result, 'EN_sg');
    });
  });
}
