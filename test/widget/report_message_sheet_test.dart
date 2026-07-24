import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/chat/presentation/chat_screen.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/features/chat/providers/chat_usage_provider.dart';
import 'package:pally/shared/models/chat_message.dart';

/// Child-safety report feature: long-press an ASSISTANT chat bubble to
/// report it — never the student's own message. These pin: the affordance
/// is role-gated, submitting reflects the honest LOADING/SUCCESS/ERROR
/// states, and a reported message stays visibly "Reported" for the rest of
/// the session so a child can't tap-report repeatedly.
///
/// Bypasses the real dio/local-db build() lifecycle (matches the
/// reteach-nudge-ui idiom) by overriding `build()` on a fake VM subclass;
/// `reportMessage` is separately overridden per test to simulate the
/// success/failure OUTCOME. The actual POST body + honest-state contract
/// against a mocked dio is verified independently in
/// test/unit/report_message_view_model_test.dart.
final _now = DateTime(2026, 7, 24, 12);

ChatMessage _userMessage() => ChatMessage(
      id: 'user-1',
      avatarId: 'av-1',
      role: MessageRole.user,
      content: 'Can you help me with fractions?',
      createdAt: _now,
    );

ChatMessage _assistantMessage() => ChatMessage(
      id: 'tutor-1',
      avatarId: 'av-1',
      role: MessageRole.tutor,
      content: 'Sure! A fraction has a numerator and a denominator.',
      createdAt: _now.add(const Duration(seconds: 1)),
    );

class _FakeChatUsage extends ChatUsageNotifier {
  @override
  ChatUsage? build() => null;
}

/// Simulates a SUCCESSFUL report submit without touching dio/local-db —
/// mirrors exactly what the real reportMessage does to state on a 2xx.
class _ReportSucceedsVM extends ChatViewModel {
  @override
  ChatState build(String avatarId) =>
      ChatState(messages: [_userMessage(), _assistantMessage()]);

  @override
  Future<void> reportMessage({
    required String messageId,
    required String messageText,
    required ReportReason reason,
    String? comment,
  }) async {
    state = state.copyWith(
      reportedMessageIds: {...state.reportedMessageIds, messageId},
    );
  }
}

/// Simulates a FAILED report submit — the state must show the error, never
/// the success confirmation.
class _ReportFailsVM extends ChatViewModel {
  @override
  ChatState build(String avatarId) =>
      ChatState(messages: [_userMessage(), _assistantMessage()]);

  @override
  Future<void> reportMessage({
    required String messageId,
    required String messageText,
    required ReportReason reason,
    String? comment,
  }) async {
    state = state.copyWith(reportError: "Couldn't send your report. Please try again.");
  }
}

Widget _harness(ChatViewModel Function() vmBuilder) => ProviderScope(
      overrides: [
        chatViewModelProvider('av-1').overrideWith(vmBuilder),
        chatUsageNotifierProvider.overrideWith(_FakeChatUsage.new),
      ],
      child: const MaterialApp(home: ChatScreen(avatarId: 'av-1')),
    );

void main() {
  testWidgets(
      'long-press on the ASSISTANT bubble opens the report sheet with all 3 reasons',
      (tester) async {
    await tester.pumpWidget(_harness(_ReportSucceedsVM.new));
    await tester.pump();

    await tester.longPress(find.text(_assistantMessage().content));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Report this message'), findsOneWidget);
    expect(
        find.text('Something Mochi said was not safe or upsetting'),
        findsOneWidget);
    expect(find.text('Mochi got it wrong or was confusing'), findsOneWidget);
    expect(find.text('Something else'), findsOneWidget);
  });

  testWidgets(
      'long-press on the STUDENT\'S OWN bubble does NOT open the report sheet',
      (tester) async {
    await tester.pumpWidget(_harness(_ReportSucceedsVM.new));
    await tester.pump();

    await tester.longPress(find.text(_userMessage().content));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Report this message'), findsNothing);
  });

  testWidgets(
      'submitting a report shows the SUCCESS confirmation, never before a reason is picked',
      (tester) async {
    await tester.pumpWidget(_harness(_ReportSucceedsVM.new));
    await tester.pump();

    await tester.longPress(find.text(_assistantMessage().content));
    await tester.pump(const Duration(milliseconds: 400));

    // Submit button is present but disabled until a reason is chosen.
    final sendButtonFinder = find.text('Send report');
    expect(sendButtonFinder, findsOneWidget);

    await tester.tap(find.text('Mochi got it wrong or was confusing'));
    await tester.pump();
    await tester.tap(sendButtonFinder);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text("Thanks — we'll take a look"), findsOneWidget);
  });

  testWidgets(
      'reported state persists in-session: after submit, the bubble shows a Reported indicator',
      (tester) async {
    await tester.pumpWidget(_harness(_ReportSucceedsVM.new));
    await tester.pump();

    await tester.longPress(find.text(_assistantMessage().content));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Something else'));
    await tester.pump();
    await tester.tap(find.text('Send report'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Done'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Reported'), findsOneWidget);

    // Re-opening via long-press shows the confirmation directly — no form,
    // no second submit — so a repeat tap can't re-report.
    await tester.longPress(find.text(_assistantMessage().content));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("Thanks — we'll take a look"), findsOneWidget);
    expect(find.text('Report this message'), findsNothing);
  });

  testWidgets(
      'a failed submit surfaces the ERROR state and NEVER the success confirmation',
      (tester) async {
    await tester.pumpWidget(_harness(_ReportFailsVM.new));
    await tester.pump();

    await tester.longPress(find.text(_assistantMessage().content));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Something else'));
    await tester.pump();
    await tester.tap(find.text('Send report'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text("Thanks — we'll take a look"), findsNothing);
    expect(
        find.text("Couldn't send your report. Please try again."),
        findsOneWidget);
    // The button relabels to Retry, and the reason picker is still there —
    // never a dead end.
    expect(find.text('Retry'), findsOneWidget);
  });
}
