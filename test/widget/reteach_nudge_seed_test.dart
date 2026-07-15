import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/router.dart';
import 'package:pally/features/chat/presentation/chat_screen.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/features/chat/providers/chat_usage_provider.dart';

/// feat/reteach-nudge-ui: the weak-concept nudge deep-links the tutor chat with a PREFILLED
/// (not auto-sent) composer. These pin: the ChatRoute carries the seed as a query param, and
/// ChatScreen pre-fills the composer from it without sending.
class _FakeChatVM extends ChatViewModel {
  @override
  ChatState build(String avatarId) => const ChatState();
}

/// Skips the network usage refresh that ChatUsageNotifier.build() fires.
class _FakeChatUsage extends ChatUsageNotifier {
  @override
  ChatUsage? build() => null;
}

List<Override> _overrides() => [
      chatViewModelProvider('av-1').overrideWith(_FakeChatVM.new),
      chatUsageNotifierProvider.overrideWith(_FakeChatUsage.new),
    ];

void main() {
  const seed = 'Can we review Closing? I keep getting it wrong';

  test('ChatRoute carries the seed as a query param (nudge → chat deep-link)', () {
    final loc = const ChatRoute(avatarId: 'av-1', seed: seed).location;
    expect(loc, contains('/avatar/av-1/chat'));
    expect(loc, contains('seed='));
    // No seed → no query param (old callers unaffected).
    expect(const ChatRoute(avatarId: 'av-1').location, isNot(contains('seed=')));
  });

  testWidgets('ChatScreen prefills the composer from seed and does NOT auto-send',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: _overrides(),
      child: const MaterialApp(home: ChatScreen(avatarId: 'av-1', seed: seed)),
    ));
    await tester.pump();

    // The seed sits in the composer (prefilled), visible and editable — not sent.
    expect(find.widgetWithText(TextField, seed), findsOneWidget);
  });

  testWidgets('ChatScreen with no seed leaves the composer empty', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: _overrides(),
      child: const MaterialApp(home: ChatScreen(avatarId: 'av-1')),
    ));
    await tester.pump();
    expect(find.widgetWithText(TextField, seed), findsNothing);
  });
}
