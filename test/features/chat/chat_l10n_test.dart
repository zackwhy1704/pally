import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Pins the chat daily-cap ICU plural + a few zh chrome strings.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('messages-left counter pluralizes in en, invariant in zh', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(en.chatMessagesLeftToday(1), '1 message left today');
    expect(en.chatMessagesLeftToday(5), '5 messages left today');

    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(zh.chatMessagesLeftToday(1), '今天还剩 1 条消息');
    expect(zh.chatMessagesLeftToday(5), '今天还剩 5 条消息');
  });

  test('chat chrome localizes; reused library key resolves', () async {
    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(zh.chatInputHint, '问我任何问题……');
    expect(zh.chatSnap, '拍照');
    // reused, not re-minted; mascot now resolves via {mascot} (zh 小伴)
    expect(zh.libraryEmptyTitle(zh.mascotName), '还没有 小伴');
  });
}
