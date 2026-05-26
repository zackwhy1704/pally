import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/pally_app.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/local_db/pally_database.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/chat/data/local/chat_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted auth credentials before first frame.
  await AuthNotifier.instance.load();

  final prefs = await SharedPreferences.getInstance();
  final router = buildAppRouter();

  final db = PallyDatabase();
  _runDailyMaintenanceIfNeeded(db, prefs);

  runApp(
    ProviderScope(
      overrides: [
        pallyDatabaseProvider.overrideWithValue(db),
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
    appLog.i('[Prune] Daily maintenance complete — ${avatarIds.length} avatars cleaned');
  } catch (e, st) {
    appLog.w('[Prune] Daily maintenance failed', error: e, stackTrace: st);
  }
}
