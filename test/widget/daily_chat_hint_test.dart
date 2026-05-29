import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/chat/presentation/chat_screen.dart';
import 'package:pally/features/chat/providers/chat_usage_provider.dart';

/// Render the hint widget with a stub usage state — no network. Locks
/// the three states the kid sees:
///  - hidden (loading / premium / plenty left)
///  - "N left today" (within 5 of cap)
///  - "Daily chats done…" (at zero)
class _StubUsage extends ChatUsageNotifier {
  _StubUsage(this._initial);
  final ChatUsage? _initial;
  @override
  ChatUsage? build() => _initial;
}

Widget _wrap(ChatUsage? usage) {
  return ProviderScope(
    overrides: [
      chatUsageNotifierProvider.overrideWith(() => _StubUsage(usage)),
    ],
    child: const MaterialApp(
      home: Scaffold(body: DailyChatHint()),
    ),
  );
}

void main() {
  testWidgets('hides when usage is null (loading)', (tester) async {
    await tester.pumpWidget(_wrap(null));
    expect(find.byType(Container), findsNothing);
    expect(find.textContaining('left today'), findsNothing);
  });

  testWidgets('hides for premium users', (tester) async {
    await tester.pumpWidget(_wrap(const ChatUsage(
      isPremium: true,
      used: 100,
      limit: null,
    )));
    expect(find.textContaining('left today'), findsNothing);
  });

  testWidgets('hides when 6 or more chats remain', (tester) async {
    await tester.pumpWidget(_wrap(const ChatUsage(
      isPremium: false,
      used: 14,
      limit: 20,
    )));
    expect(find.textContaining('left today'), findsNothing);
  });

  testWidgets('shows N-left copy at the 5-left threshold', (tester) async {
    await tester.pumpWidget(_wrap(const ChatUsage(
      isPremium: false,
      used: 15,
      limit: 20,
    )));
    expect(find.text('5 messages left today'), findsOneWidget);
  });

  testWidgets('singular copy at 1 left', (tester) async {
    await tester.pumpWidget(_wrap(const ChatUsage(
      isPremium: false,
      used: 19,
      limit: 20,
    )));
    expect(find.text('1 message left today'), findsOneWidget);
  });

  testWidgets('shows "Daily chats done" at zero', (tester) async {
    await tester.pumpWidget(_wrap(const ChatUsage(
      isPremium: false,
      used: 20,
      limit: 20,
    )));
    expect(find.textContaining('Daily chats done'), findsOneWidget);
    expect(find.textContaining('Premium'), findsOneWidget);
  });
}
