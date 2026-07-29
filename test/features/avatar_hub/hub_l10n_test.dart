import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Pins the avatar-hub ICU plural + placeholder strings, including the middle-dot
/// separator (·, U+00B7) that a widget test asserts by exact match.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dot = '·'; // middle dot

  test('module subtitle pluralizes in en, is invariant in zh', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(en.hubModulesSubtitle(1, 50), '1 module $dot 50% mastery');
    expect(en.hubModulesSubtitle(3, 40), '3 modules $dot 40% mastery');

    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(zh.hubModulesSubtitle(1, 50), '1 个单元 $dot 掌握度 50%');
    expect(zh.hubModulesSubtitle(3, 40), '3 个单元 $dot 掌握度 40%');
  });

  test('quiz-mastered placeholders + chrome localize', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(en.hubQuizSubtitleMastered(2, 5), 'Test yourself $dot 2/5 mastered');
    expect(en.hubLearn, 'Learn');

    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(zh.hubQuizSubtitleMastered(2, 5), '考考自己 $dot 已掌握 2/5');
    expect(zh.hubLearn, '学习');
    expect(zh.hubClassBadge, '班级');
    expect(zh.hubSectionProveIt, '证明掌握');
  });
}
