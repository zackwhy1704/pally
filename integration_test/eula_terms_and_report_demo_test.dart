// App-Store/Play-Store demo-recording driver — Pixel 8 (physical device) variant.
// Beats: Signup -> "Read full Terms of Use" (external Chrome, scroll, back) ->
// blocked Create-account tap -> checked Create-account -> chat -> long-press ->
// report -> submit.
//
// Run against the connected Pixel 8 while a screen recording is capturing
// (see RUNBOOK.md / the accompanying terms_link_chrome_detour.sh). Every
// correctness wait polls real app/provider/lifecycle state — never a blind
// sleep — matching the source repo's own layering-guard philosophy. The
// deliberate LEGIBILITY holds requested on top of that are separate, explicit
// `_beat()` calls so the two concerns never get confused in the diff.
//
//   flutter test integration_test/eula_terms_and_report_demo_test.dart \
//     -d adb-49051FDJH002K5-gXzTjP._adb-tls-connect._tcp

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

/// Observes real OS-delivered app lifecycle transitions (backgrounded when
/// Chrome takes over for the external Terms link, resumed when the device's
/// BACK action returns focus to us). This is the correctness wait for the
/// external-browser detour — never a blind sleep.
class _LifecycleWatcher with WidgetsBindingObserver {
  AppLifecycleState? state;

  _LifecycleWatcher() {
    WidgetsBinding.instance.addObserver(this);
    state = WidgetsBinding.instance.lifecycleState;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) => state = s;

  void dispose() => WidgetsBinding.instance.removeObserver(this);
}

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

/// A deliberate, human-watchable dwell — the "hold after action" column in
/// the recording script. Distinct from `_pumpUntil`, which waits for
/// correctness; this exists purely for legibility on camera.
Future<void> _hold(WidgetTester tester, Duration d) async {
  final deadline = DateTime.now().add(d);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo: Terms link, EULA gate, then chat report flow', (tester) async {
    final lifecycle = _LifecycleWatcher();
    addTearDown(lifecycle.dispose);

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

    // ── Reach the signup wizard, step 1 (fast — not part of the recorded beats) ──
    router.go('/onboarding/direct');
    await _pumpUntilFound(tester, find.byType(TextFormField));

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
    await tester.pump();

    final nextBtn = find.text(_l.signupNext);
    await tester.ensureVisible(nextBtn);
    await tester.tap(nextBtn);

    // ── Beat: "Launch app, navigate to signup step 2" — hold 0.5s ──────────
    await _pumpUntilFound(tester, find.byType(ChoiceChip));
    await _hold(tester, const Duration(milliseconds: 500));

    // ── Beat: tap "Read the full Terms of Use" — external Chrome detour ────
    final termsLink = find.text(_l.signupViewFullTerms);
    await tester.ensureVisible(termsLink);
    await tester.tap(termsLink);

    // Correctness wait: the OS actually backgrounded us for Chrome. A
    // companion host-side adb script (terms_link_chrome_detour.sh) does the
    // real on-screen work here — poll-for-Chrome, hold 2.5s, slow scroll,
    // hold 1.5s, BACK — while we wait for the real lifecycle transition
    // rather than guessing its duration with a sleep.
    await _pumpUntil(
      tester,
      () => lifecycle.state == AppLifecycleState.paused ||
          lifecycle.state == AppLifecycleState.inactive,
      timeout: const Duration(seconds: 15),
      description: 'app backgrounded for external Terms page',
    );
    await _pumpUntil(
      tester,
      () => lifecycle.state == AppLifecycleState.resumed,
      timeout: const Duration(seconds: 30),
      description: 'app resumed after external Terms page',
    );
    // "Navigate back to signup" — hold 0.5s.
    await _hold(tester, const Duration(milliseconds: 500));

    // ── Beat: tap "Create account" WITH checkbox unchecked — blocked ───────
    final subjectChip = find.byType(ChoiceChip).first;
    await tester.ensureVisible(subjectChip);
    await tester.tap(subjectChip);
    await tester.pump();

    final levelTile = find.text(_l.levelPrimary);
    await tester.ensureVisible(levelTile);
    await tester.tap(levelTile);
    await tester.pump();

    final checkbox = find.byType(Checkbox);
    final createBtn = find.text(_l.signupCreateAccount);
    await tester.ensureVisible(createBtn);
    await tester.tap(createBtn);
    await _hold(tester, const Duration(seconds: 2)); // disabled state reads clearly
    expect(find.text(_l.signupCreateAccount), findsOneWidget,
        reason: 'unchecked tap must not navigate past step 2');

    // ── Beat: check the box — enabled-state change visible ─────────────────
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await _hold(tester, const Duration(seconds: 1));

    // ── Beat: "Create account" for real — wait for the transition, hold 1s ─
    await tester.ensureVisible(find.text(_l.signupCreateAccount));
    await tester.tap(find.text(_l.signupCreateAccount));
    await _pumpUntilFound(
      tester,
      find.text(_l.signupAddFirstNotes),
      timeout: const Duration(seconds: 30),
    );
    await _hold(tester, const Duration(seconds: 1));

    final avatarId = container.read(directOnboardingViewModelProvider).avatarId;
    expect(avatarId, isNotNull, reason: 'quickOnboard must have created an avatar');

    // Skip notes upload — not one of the requested beats.
    final skipBtn = find.text(_l.signupSkipForNow);
    await tester.ensureVisible(skipBtn);
    await tester.tap(skipBtn);
    await tester.pump();

    // ── Beat: enter chat, get a real (not pre-seeded) Mochi reply ───────────
    router.go('/avatar/$avatarId/chat');
    await _pumpUntilFound(tester, find.byType(FloatingActionButton));

    await tester.enterText(find.byType(TextField).first, 'What is 7 times 8?');
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));

    await _pumpUntil(
      tester,
      () => container
          .read(chatViewModelProvider(avatarId!))
          .messages
          .any((m) =>
              m.role == MessageRole.tutor && !m.isStreaming && m.content.isNotEmpty),
      timeout: const Duration(seconds: 45),
      description: 'assistant reply to finish streaming',
    );
    // "Navigate into a chat with an existing message from Mochi" — hold 1.0s.
    await _hold(tester, const Duration(seconds: 1));

    // ── Beat: long-press the message — opens the report sheet directly ─────
    // (There's no separate "Report this message" tap target on this build —
    // the long-press IS the trigger. Folding your two 1.5s/2.0s holds into
    // one dwell on the now-open sheet.)
    final reportGesture = find.byWidgetPredicate(
      (w) => w is GestureDetector && w.onLongPress != null,
    );
    await _pumpUntilFound(tester, reportGesture);
    await tester.ensureVisible(reportGesture.first);
    await tester.longPress(reportGesture.first);
    await _pumpUntilFound(tester, find.text(_l.reportTitle));
    await _hold(tester, const Duration(milliseconds: 1500));
    await _hold(tester, const Duration(seconds: 2));

    // ── Beat: pick "Something else", hold 1.0s ──────────────────────────────
    final otherReason = find.text(_l.reportReasonOther);
    await tester.ensureVisible(otherReason);
    await tester.tap(otherReason);
    await _hold(tester, const Duration(seconds: 1));

    // ── Beat: "Send report" — wait for the real submit, hold 2.0s ──────────
    final sendReportBtn = find.text(_l.reportSend);
    await tester.ensureVisible(sendReportBtn);
    await tester.tap(sendReportBtn);
    await _pumpUntilFound(
      tester,
      find.text(_l.reportThanks),
      timeout: const Duration(seconds: 20),
    );
    await _hold(tester, const Duration(seconds: 2));

    // ── End — hold 1.0s before teardown ─────────────────────────────────────
    await _hold(tester, const Duration(seconds: 1));
  });
}
