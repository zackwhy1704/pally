import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/i18n/label_localizer.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Pins the subject/level/tier localizer — and above all the LOAD-BEARING rule:
/// a known enum subject is localized, but an unknown (free-text) subject a teacher
/// typed is passed through UNCHANGED. Getting that backwards means either machine-
/// translating a teacher's own words or leaving 数学 as "Maths".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations en;
  late AppLocalizations zh;
  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    zh = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  group('localizedSubject', () {
    test('known subject localizes — from the backend CODE form', () {
      expect(localizedSubject(en, 'MATHS'), 'Maths');
      expect(localizedSubject(zh, 'MATHS'), '数学');
      expect(localizedSubject(zh, 'SCIENCE'), '科学');
    });

    test('known subject localizes — from the title-cased DISPLAY form too', () {
      // avatar.subject is stored as 'Maths'/'Physical Education', not the code.
      expect(localizedSubject(zh, 'Maths'), '数学');
      expect(localizedSubject(zh, 'Physical Education'), '体育');
      expect(localizedSubject(en, 'Physical Education'), 'Physical Education');
    });

    test('UNKNOWN free-text subject passes through UNCHANGED in every locale', () {
      // A teacher typed their own subject in create-tutor. Never translate it,
      // never blank it — reproduce it exactly.
      const custom = 'Underwater Basket Weaving';
      expect(localizedSubject(en, custom), custom);
      expect(localizedSubject(zh, custom), custom, reason: 'must NOT machine-translate');
      expect(localizedSubject(zh, '海洋生物学'), '海洋生物学');
    });
  });

  group('localizedLevel / subtitle', () {
    test('known stage localizes; unknown passes through', () {
      expect(localizedLevel(zh, 'PRIMARY'), '小学');
      expect(localizedLevel(zh, 'HIGH_SCHOOL'), '高中');
      expect(localizedLevel(en, 'GRADUATE'), 'GRADUATE'); // passthrough
    });

    test('subtitle localizes for known stages, empty for unknown', () {
      expect(localizedLevelSubtitle(zh, 'PRIMARY'), '约 6–11 岁');
      expect(localizedLevelSubtitle(en, 'PRIMARY'), 'Ages ~6–11');
      expect(localizedLevelSubtitle(en, 'GRADUATE'), '');
    });
  });

  group('localizedTier', () {
    test('null/blank → the Premium default', () {
      expect(localizedTier(en, null), 'Premium');
      expect(localizedTier(zh, null), '高级版');
      expect(localizedTier(zh, '   '), '高级版');
    });

    test('known tiers localize; unknown title-cases through', () {
      expect(localizedTier(zh, 'free'), '免费');
      expect(localizedTier(zh, 'family'), '家庭');
      expect(localizedTier(en, 'free'), 'Free');
      expect(localizedTier(en, 'enterprise'), 'Enterprise'); // passthrough, title-cased
    });
  });
}
