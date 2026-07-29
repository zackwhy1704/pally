import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Pins the library ICU plural + placeholder strings across locales — the real
/// count-plural (en distinguishes 1 vs N; zh has no plural, so both use `other`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('brain-page count pluralizes in en, is invariant in zh', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(en.libraryStatusBrainPages(1), '🧠 1 brain page');
    expect(en.libraryStatusBrainPages(3), '🧠 3 brain pages');

    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(zh.libraryStatusBrainPages(1), '🧠 1 个知识页');
    expect(zh.libraryStatusBrainPages(3), '🧠 3 个知识页');
  });

  test('building-brain plural + chrome + name placeholders localize', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(en.libraryStatusBuilding(1), '⏳ Building brain from 1 file…');
    expect(en.libraryStatusBuilding(2), '⏳ Building brain from 2 files…');
    expect(en.libraryAvatarDeleted('Sakura'), 'Sakura deleted');

    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(zh.libraryTitle, '学习库');
    expect(zh.libraryAvatarDeleted('小明'), '已删除 小明');
    expect(zh.libraryLeftClass('P5 科学'), '已退出 P5 科学');
  });
}
