import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/i18n/app_languages.dart';

/// The registry is the single source of truth for the client's language set.
/// These tests pin the invariants the rest of the app relies on — especially
/// the fallback chain, which is what keeps an unknown/garbage locale from
/// crashing or half-localising a screen (B-EXT.3).
void main() {
  group('AppLanguages.byCode', () {
    test('resolves an exact registry code', () {
      expect(AppLanguages.byCode('en'), AppLanguages.english);
      expect(AppLanguages.byCode('zh'), AppLanguages.chinese);
    });

    test('is case-insensitive and ignores region/script suffix', () {
      // A device locale like zh-Hans-SG or en_US must still resolve to the
      // primary-subtag registry entry, not fall through to the fallback.
      expect(AppLanguages.byCode('ZH'), AppLanguages.chinese);
      expect(AppLanguages.byCode('zh-Hans-SG'), AppLanguages.chinese);
      expect(AppLanguages.byCode('en_US'), AppLanguages.english);
    });

    test('returns null for an unsupported or null code', () {
      expect(AppLanguages.byCode('ms'), isNull); // not yet in the registry
      expect(AppLanguages.byCode('garbage'), isNull);
      expect(AppLanguages.byCode(null), isNull);
    });
  });

  group('AppLanguages.resolve — fallback chain (requested → device → en)', () {
    test('uses the requested language when supported', () {
      expect(AppLanguages.resolve(requested: 'zh', device: 'en'),
          AppLanguages.chinese);
    });

    test('falls back to device when requested is unsupported/absent', () {
      expect(AppLanguages.resolve(requested: null, device: 'zh'),
          AppLanguages.chinese);
      expect(AppLanguages.resolve(requested: 'ms', device: 'zh'),
          AppLanguages.chinese);
    });

    test('falls back to English when neither is supported', () {
      expect(AppLanguages.resolve(requested: 'ms', device: 'fr'),
          AppLanguages.fallback);
      expect(AppLanguages.resolve(requested: null, device: null),
          AppLanguages.english);
    });

    test('never returns null — an unknown code degrades, it does not crash', () {
      expect(AppLanguages.resolve(requested: 'zzz', device: 'qqq'), isNotNull);
    });
  });

  group('registry shape', () {
    test('supportedLocales is derived from all (not hand-listed)', () {
      expect(AppLanguages.locales,
          AppLanguages.all.map((l) => l.locale).toList());
    });

    test('English is first and is the fallback', () {
      expect(AppLanguages.all.first, AppLanguages.english);
      expect(AppLanguages.fallback, AppLanguages.english);
    });

    test('every entry has a non-empty code and endonym', () {
      for (final l in AppLanguages.all) {
        expect(l.code, isNotEmpty);
        expect(l.endonym, isNotEmpty);
        expect(l.locale.languageCode, l.code);
      }
    });
  });
}
