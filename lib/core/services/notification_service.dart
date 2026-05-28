import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:pally/core/utils/logger.dart';

/// Wraps flutter_local_notifications for the daily quiz reminder.
///
/// Call [init] once from main() before runApp. Then settings UI can call
/// [scheduleDailyQuizReminder] / [cancelDailyQuizReminder] freely.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _quizChannelId = 'daily_quiz';
  static const _quizNotificationId = 1001;
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

  static Future<void> scheduleDailyQuizReminder(int hour, int minute) async {
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
        title: 'Quiz time!',
        body: 'Your daily quiz is waiting — earn XP and keep your streak!',
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _quizChannelId,
            'Daily Quiz Reminder',
            channelDescription: 'Reminds you to take your daily quiz',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
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
}
