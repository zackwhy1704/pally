import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/app/pally_app.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/local_db/pally_database.dart';
import 'package:pally/core/observability/sentry_observability.dart';
import 'package:pally/core/services/notification_service.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/chat/data/local/chat_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Framework error hooks ─────────────────────────────────────────────────
  // Route Flutter widget/render exceptions AND escaped async errors through
  // SentryObservability, which forwards to BOTH appLog (greppable in logcat)
  // and Sentry (in release + DSN present). In debug/no-DSN: appLog only.
  FlutterError.onError = SentryObservability.reportFlutterError;
  WidgetsBinding.instance.platformDispatcher.onError =
      SentryObservability.reportError;

  // Wrap the entire bootstrap in Sentry + runZonedGuarded so escaped async
  // errors reach appLog instead of vanishing silently.
  await SentryObservability.run(_bootstrap);
}

Future<void> _bootstrap() async {
  // Initialise Firebase — non-fatal so dev/CI builds work without config.
  try {
    await Firebase.initializeApp();
    // Handle foreground FCM messages via existing local-notification service.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        appLog.d(
          '[FCM] Foreground: ${message.notification?.title}',
        );
      }
    });
  } catch (e) {
    appLog.w('[Firebase] Init failed (non-fatal): $e');
  }

  // Load persisted auth credentials before first frame.
  await AuthNotifier.instance.load();

  // Initialise local notifications. Non-fatal if it fails.
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();

  // Shared NavigatorState key so the global server-error interceptor can
  // reach a BuildContext for toasts when no screen owns the failed call.
  final navigatorKey = GlobalKey<NavigatorState>();
  final router = buildAppRouter(navigatorKey: navigatorKey);

  final db = PallyDatabase();
  _runDailyMaintenanceIfNeeded(db, prefs);

  runApp(
    ProviderScope(
      overrides: [
        pallyDatabaseProvider.overrideWithValue(db),
        globalNavigatorKeyProvider.overrideWithValue(navigatorKey),
      ],
      child: PallyApp(router: router),
    ),
  );
}

void _runDailyMaintenanceIfNeeded(
    PallyDatabase db, SharedPreferences prefs) async {
  const lastPruneKey = 'last_prune_date';
  final lastPrune = prefs.getString(lastPruneKey);
  final today = DateTime.now().toIso8601String().substring(0, 10);

  if (lastPrune == today) return;

  final local = ChatLocalDataSource(db);

  try {
    final avatarIds = await (db.selectOnly(db.chatMessages)
          ..addColumns([db.chatMessages.avatarId])
          ..groupBy([db.chatMessages.avatarId]))
        .map((row) => row.read(db.chatMessages.avatarId)!)
        .get();

    for (final avatarId in avatarIds) {
      await local.pruneOldMessages(avatarId, days: 90);
      await local.pruneExcessMessages(avatarId, maxMessages: 500);
      appLog.i('[Prune] Cleaned messages for avatar=$avatarId');
    }

    await prefs.setString(lastPruneKey, today);
    appLog.i(
        '[Prune] Daily maintenance complete — ${avatarIds.length} avatars cleaned');
  } catch (e, st) {
    appLog.w('[Prune] Daily maintenance failed', error: e, stackTrace: st);
  }
}
