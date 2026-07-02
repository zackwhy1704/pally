import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/services/firebase_ready.dart';
import 'package:pally/core/theme/app_theme.dart';
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
    // Launch check (backbone): a parent may have approved while the app was
    // fully closed. One check on startup — no loop. No-ops unless awaiting consent.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(consentUnlockProvider).checkAndUnlock();
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
        ref.read(consentUnlockProvider).checkAndUnlock();
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
      // backgrounded (e.g. overnight). One check per resume — never a poll.
      // No-ops unless the child is awaiting consent.
      ref.read(consentUnlockProvider).checkAndUnlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pally',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
