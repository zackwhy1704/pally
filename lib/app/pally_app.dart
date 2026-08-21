import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/features/flashcards/providers/srs_reminder_armer.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/core/services/firebase_ready.dart';
import 'package:pally/features/voice_input/data/voice_input_prefs.dart';
import 'package:pally/core/theme/app_theme.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/consent/data/consent_unlock.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';

class PallyApp extends ConsumerStatefulWidget {
  const PallyApp({super.key, GoRouter? router}) : _router = router;

  final GoRouter? _router;

  @override
  ConsumerState<PallyApp> createState() => _PallyAppState();
}

class _PallyAppState extends ConsumerState<PallyApp>
    with WidgetsBindingObserver {
  late final GoRouter _router = widget._router ?? appRouter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wireConsentPush();
    // Launch reconcile (backbone): drive the consent gate from the SERVER's
    // accountStatus, not the local flag — so an approved child unlocks even if
    // the local awaitingConsent flag desynced (reinstall / other device / normal
    // sign-in). One authoritative check on startup — no loop. No-ops when signed out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(consentUnlockProvider).reconcile();
      // Arm the SM-2 review reminder at LAUNCH. Previously the only arm site was
      // inside the flashcard deck screen, so the reminder meant to bring a student
      // BACK to flashcards could only be set while they were already there — and it
      // never fired at all for the many students whose cards were generated
      // server-side during wiki compile. Idempotent (cancel-then-reschedule, one
      // slot per avatar), so launch + resume re-point the same slot.
      ref.read(srsReminderArmerProvider).armAll();
    });
  }

  /// Parental-consent approval is an async event on the PARENT's timeline. Push
  /// is the primary (instant-feeling) trigger: handle it in foreground, on tap
  /// from background, and on cold-start-from-notification. Each fires a SINGLE
  /// consent re-check — never a poll.
  void _wireConsentPush() {
    // Never touch FirebaseMessaging if Firebase failed to initialise —
    // FirebaseMessaging.instance would throw [core/no-app] here in the startup
    // widget path and red-screen the whole app. Push-based unlock degrades
    // silently; the resume-check + launch-check backbone still unlocks.
    if (!isFirebaseReady) {
      appLog.w('[Consent] Firebase not ready — skipping push wiring '
          '(resume/launch check still active)');
      return;
    }

    void handle(RemoteMessage? m) {
      if (m?.data['type'] == 'PARENTAL_CONSENT_APPROVED') {
        ref.read(consentUnlockProvider).reconcile();
      }
    }

    FirebaseMessaging.onMessage.listen(handle);       // foreground
    FirebaseMessaging.onMessageOpenedApp.listen(handle); // tapped from background
    // Cold start from a notification tap.
    FirebaseMessaging.instance.getInitialMessage().then(handle);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Purchasing happens on the web, so a user may upgrade while the app is
      // backgrounded. On resume, silently reconcile entitlement so a web
      // purchase unlocks the app with no manual refresh.
      ref.read(entitlementVmProvider.notifier).reconcile();
      // Consent unlock backbone: a parent may have approved while the app was
      // backgrounded (e.g. overnight). Use the AUTHORITATIVE reconcile (server
      // truth) — same as launch — so a resume unlocks even if the local
      // awaiting-consent flag desynced. One check per resume — never a poll.
      ref.read(consentUnlockProvider).reconcile();
      // Re-arm the review reminder on resume: due counts drift while the app is
      // backgrounded (cards come due overnight), and a reinstall/device change
      // wipes the device-local slot entirely. Same idempotent per-avatar slot.
      ref.read(srsReminderArmerProvider).armAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Server-controlled voice-input kill-switch: mirror the `voice_input` feature
    // flag (Railway VOICE_INPUT_ENABLED) into voiceInputEnabledProvider from the ONE
    // place flags are already loaded, so mic-bearing widgets don't each pull the async
    // flags/auth graph. Fail-closed: stays false until a confirmed server flag turns it on.
    ref.listen(featureFlagsProvider, (prev, next) {
      final on = voiceEnabledFromFlags(next.valueOrNull);
      if (ref.read(voiceInputEnabledProvider) != on) {
        ref.read(voiceInputEnabledProvider.notifier).state = on;
      }
    });
    // UI language: driven by the locale controller (persisted device pref →
    // live rebuild on change). Delegates + supportedLocales derive from the
    // AppLanguages registry via generated AppLocalizations — no hand-listed set.
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp.router(
      title: 'Pally',
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
