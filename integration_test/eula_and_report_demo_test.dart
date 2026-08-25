// App-Store demo-recording driver. NOT a correctness test — it drives the
// real app (real backend, real navigation, real LLM chat) through the exact
// beats Apple asked to see on video:
//   1. Signup -> pause on the EULA checkbox (zero-tolerance clause legible)
//   2. Tap "Create account" unchecked -> blocked
//   3. Check the box -> account created
//   4. Enter chat -> long-press the assistant reply -> report -> submit
//
// Run against a booted simulator/device while `xcrun simctl io booted
// recordVideo demo.mov` (or QuickTime) is capturing:
//   flutter test integration_test/eula_and_report_demo_test.dart -d <device>
//
// Every wait below polls real app/provider state instead of `pumpAndSettle()`
// because this screen tree has indeterminate (repeating) spinners — loading
// buttons, the onboarding processing view — which never "settle".

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pally/app/api_client.dart' show globalNavigatorKeyProvider;
import 'package:pally/app/pally_app.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/i18n/locale_controller.dart' show initialLocaleProvider;
import 'package:pally/core/local_db/pally_database.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_view_model.dart';
import 'package:pally/l10n/app_localizations_en.dart';
import 'package:pally/shared/models/chat_message.dart';

final _l = AppLocalizationsEn();

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 30),
  Duration step = const Duration(milliseconds: 250),
  String? description,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for: ${description ?? condition}');
    }
    await tester.pump(step);
  }
  // Let the frame that satisfied the condition finish building.
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) =>
    _pumpUntil(
      tester,
      () => finder.evaluate().isNotEmpty,
      timeout: timeout,
      description: finder.toString(),
    );

/// A human-watchable dwell so the recorded video shows each state instead of
/// flickering past it in a single frame.
Future<void> _beat(WidgetTester tester, [Duration d = const Duration(milliseconds: 700)]) async {
  await tester.pump(d);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo: EULA gate then chat report flow', (tester) async {
    await AuthNotifier.instance.load();
    await AuthNotifier.instance.signOut();

    final navigatorKey = GlobalKey<NavigatorState>();
    final router = buildAppRouter(navigatorKey: navigatorKey);
    final db = PallyDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pallyDatabaseProvider.overrideWithValue(db),
          globalNavigatorKeyProvider.overrideWithValue(navigatorKey),
          initialLocaleProvider.overrideWithValue(const Locale('en')),
        ],
        child: PallyApp(router: router),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(PallyApp)),
      listen: false,
    );

    // ── Reach the signup wizard ────────────────────────────────────────────
    router.go('/onboarding/direct');
    await _pumpUntilFound(tester, find.byType(TextFormField));

    // ── Step 1: name / email / password / age group ────────────────────────
    final uniqueEmail =
        'demo-video-${DateTime.now().millisecondsSinceEpoch}@apalchi-demo.com';
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Demo Student');
    await tester.enterText(fields.at(1), uniqueEmail);
    await tester.enterText(fields.at(2), 'DemoPass123!');
    await tester.pump();

    final ageTile = find.text(_l.signupAge13OrOlder);
    await tester.ensureVisible(ageTile);
    await tester.tap(ageTile);
    await _beat(tester);

    final nextBtn = find.text(_l.signupNext);
    await tester.ensureVisible(nextBtn);
    await tester.tap(nextBtn);
    await _pumpUntilFound(tester, find.byType(ChoiceChip));

    // ── Step 2: subject / level / EULA checkbox ─────────────────────────────
    final subjectChip = find.byType(ChoiceChip).first;
    await tester.ensureVisible(subjectChip);
    await tester.tap(subjectChip);
    await _beat(tester);

    final levelTile = find.text(_l.levelPrimary);
    await tester.ensureVisible(levelTile);
    await tester.tap(levelTile);
    await _beat(tester);

    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);

    // Beat 1: pause on the checkbox so the zero-tolerance clause is legible.
    await tester.pump(const Duration(seconds: 2));

    // Beat 2: tap "Create account" while UNCHECKED -> blocked (disabled button).
    final createBtn = find.text(_l.signupCreateAccount);
    await tester.ensureVisible(createBtn);
    await tester.tap(createBtn);
    await _beat(tester, const Duration(milliseconds: 1200));
    expect(find.text(_l.signupCreateAccount), findsOneWidget,
        reason: 'unchecked tap must not navigate past step 2');

    // Beat 3: check the box -> account created.
    await tester.tap(checkbox);
    await _beat(tester);
    await tester.ensureVisible(find.text(_l.signupCreateAccount));
    await tester.tap(find.text(_l.signupCreateAccount));

    await _pumpUntilFound(
      tester,
      find.text(_l.signupAddFirstNotes),
      timeout: const Duration(seconds: 30),
    );

    final avatarId =
        container.read(directOnboardingViewModelProvider).avatarId;
    expect(avatarId, isNotNull, reason: 'quickOnboard must have created an avatar');

    // Skip notes upload — not part of the requested recording.
    final skipBtn = find.text(_l.signupSkipForNow);
    await tester.ensureVisible(skipBtn);
    await tester.tap(skipBtn);
    await _beat(tester);

    // ── Beat 4: enter chat ───────────────────────────────────────────────────
    router.go('/avatar/$avatarId/chat');
    await _pumpUntilFound(tester, find.byType(FloatingActionButton));
    await _beat(tester);

    await tester.enterText(find.byType(TextField).first, 'What is 7 times 8?');
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await _beat(tester);

    // Wait for the assistant's reply to finish streaming (real backend call).
    await _pumpUntil(
      tester,
      () => container
          .read(chatViewModelProvider(avatarId!))
          .messages
          .any((m) =>
              m.role == MessageRole.tutor &&
              !m.isStreaming &&
              m.content.isNotEmpty),
      timeout: const Duration(seconds: 45),
      description: 'assistant reply to finish streaming',
    );
    await _beat(tester);

    // Long-press the assistant bubble — it's the only GestureDetector on this
    // screen with onLongPress (the report affordance).
    final reportGesture = find.byWidgetPredicate(
      (w) => w is GestureDetector && w.onLongPress != null,
    );
    await _pumpUntilFound(tester, reportGesture);
    await tester.ensureVisible(reportGesture.first);
    await tester.longPress(reportGesture.first);
    await _pumpUntilFound(tester, find.text(_l.reportTitle));
    await _beat(tester);

    // ── Beat 5: pick a reason, submit ───────────────────────────────────────
    final unsafeReason = find.text(_l.reportReasonUnsafe(_l.mascotName));
    await tester.ensureVisible(unsafeReason);
    await tester.tap(unsafeReason);
    await _beat(tester);

    final sendReportBtn = find.text(_l.reportSend);
    await tester.ensureVisible(sendReportBtn);
    await tester.tap(sendReportBtn);

    await _pumpUntilFound(
      tester,
      find.text(_l.reportThanks),
      timeout: const Duration(seconds: 20),
    );
    await _beat(tester, const Duration(seconds: 1));

    final doneBtn = find.text(_l.reportDoneButton);
    if (doneBtn.evaluate().isNotEmpty) {
      await tester.tap(doneBtn);
      await _beat(tester);
    }
  });
}
