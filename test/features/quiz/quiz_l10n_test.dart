import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('quiz placeholders + chrome localize; reused Review key resolves', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(en.quizScoreResult(3, 5), 'You got 3 out of 5 correct.');
    expect(en.quizAnswerLabel('Carbon dioxide'), 'Answer: Carbon dioxide');
    expect(en.moduleCtaReview, 'Review');

    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(zh.quizScoreResult(3, 5), '你答对了 5 题中的 3 题。');
    expect(zh.quizCorrect, '答对了！');
    expect(zh.quizComplete, '小测完成！');
  });
}
