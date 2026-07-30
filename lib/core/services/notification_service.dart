import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:pally/core/utils/logger.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Wraps flutter_local_notifications for the daily quiz reminder.
///
/// Call [init] once from main() before runApp. Then settings UI can call
/// [scheduleDailyQuizReminder] / [cancelDailyQuizReminder] freely.
class NotificationService {
  // All user-visible notification copy arrives as an [AppLocalizations]
  // resolved by the CALLER (context, or lookupAppLocalizations(persisted
  // locale) in a view model) — this service has no BuildContext and never
  // bakes a language. A scheduled notification keeps the language it was
  // scheduled in until the next (idempotent) reschedule.
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _quizChannelId = 'daily_quiz';
  static const _srsChannelId = 'flashcard_due';
  static const _quizNotificationId = 1001;
  // SRS notifications get one slot per avatar. We hash avatarId into a stable
  // 5-digit id so reschedules deterministically overwrite the previous slot.
  static int _srsIdFor(String avatarId) =>
      2000 + (avatarId.hashCode.abs() % 90000);
  static bool _initialised = false;

  static Future<void> init() async {
    if (_initialised) return;
    try {
      tz_data.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        settings:
            const InitializationSettings(android: android, iOS: ios),
      );
      _initialised = true;
      appLog.i('[Notifications] initialised');
    } catch (e, st) {
      appLog.w('[Notifications] init failed (non-fatal)',
          error: e, stackTrace: st);
    }
  }

  static Future<void> scheduleDailyQuizReminder(
      int hour, int minute, {required AppLocalizations l10n}) async {
    if (!_initialised) await init();
    try {
      await _plugin.cancel(id: _quizNotificationId);

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
          tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: _quizNotificationId,
        title: l10n.notifQuizTitle,
        body: l10n.notifQuizBody,
        scheduledDate: scheduled,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _quizChannelId,
            l10n.notifQuizChannelName,
            channelDescription: l10n.notifQuizChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        matchDateTimeComponents: DateTimeComponents.time, // repeat daily
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      appLog.i('[Notifications] daily quiz scheduled for $hour:$minute');
    } catch (e, st) {
      appLog.w('[Notifications] schedule failed', error: e, stackTrace: st);
    }
  }

  static Future<void> cancelDailyQuizReminder() async {
    if (!_initialised) await init();
    try {
      await _plugin.cancel(id: _quizNotificationId);
      appLog.i('[Notifications] daily quiz cancelled');
    } catch (e) {
      appLog.w('[Notifications] cancel failed: $e');
    }
  }

  /// Schedules a single SRS reminder per avatar for the earliest upcoming due
  /// flashcard. Reschedule whenever the deck or any card rating changes —
  /// the call is idempotent (it cancels the previous slot first).
  ///
  /// If [earliestDue] is null or already in the past, the slot is cancelled.
  static Future<void> scheduleSrsReminder({
    required String avatarId,
    required String avatarName,
    required int dueCount,
    required DateTime? earliestDue,
    required AppLocalizations l10n,
  }) async {
    if (!_initialised) await init();
    final id = _srsIdFor(avatarId);
    try {
      await _plugin.cancel(id: id);
      if (earliestDue == null || dueCount <= 0) return;

      final scheduled =
          tz.TZDateTime.from(earliestDue.toLocal(), tz.local);
      final now = tz.TZDateTime.now(tz.local);
      if (scheduled.isBefore(now)) {
        // Cards are already due — fire today at 16:00 local instead of
        // immediately so we don't spam at app-launch time.
        final today4pm = tz.TZDateTime(
            tz.local, now.year, now.month, now.day, 16);
        final target = today4pm.isAfter(now)
            ? today4pm
            : today4pm.add(const Duration(days: 1));
        await _plugin.zonedSchedule(
          id: id,
          title: l10n.notifSrsTitle(dueCount, avatarName),
          body: l10n.notifSrsBodyOverdue,
          scheduledDate: target,
          notificationDetails: _srsDetails(l10n),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        appLog.i('[Notifications] SRS (overdue) avatar=$avatarName '
            'count=$dueCount → $target');
        return;
      }

      await _plugin.zonedSchedule(
        id: id,
        title: l10n.notifSrsTitle(dueCount, avatarName),
        body: l10n.notifSrsBody,
        scheduledDate: scheduled,
        notificationDetails: _srsDetails(l10n),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      appLog.i('[Notifications] SRS scheduled avatar=$avatarName '
          'count=$dueCount at $scheduled');
    } catch (e, st) {
      appLog.w('[Notifications] SRS schedule failed', error: e, stackTrace: st);
    }
  }

  /// Cancels the SRS slot for a given avatar (e.g. user disabled it for that
  /// tutor or the deck was emptied).
  static Future<void> cancelSrsReminder(String avatarId) async {
    if (!_initialised) await init();
    try {
      await _plugin.cancel(id: _srsIdFor(avatarId));
    } catch (_) {/* best-effort */}
  }

  static NotificationDetails _srsDetails(AppLocalizations l10n) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          _srsChannelId,
          l10n.notifSrsChannelName,
          channelDescription: l10n.notifSrsChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
}
