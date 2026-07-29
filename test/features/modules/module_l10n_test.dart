import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Pins module stage/CTA labels + reused keys across locales.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('stage + CTA labels localize; reused keys resolve', () async {
    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(zh.moduleStageLearn, '学习');
    expect(zh.moduleStageProve, '证明');
    expect(zh.moduleCtaStartLearning, '开始学习');
    expect(zh.moduleNoLessonsYet, '还没有课程');
    expect(zh.commonTryAgain, '重试'); // reused (PR2)
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(en.moduleStageLearn, 'LEARN');
    expect(en.moduleBuildFirstLesson, 'Build my first lesson');
  });
}
