import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class JournalReminderService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
  }

  static Future<void> scheduleEveningReminders() async {
    final now = tz.TZDateTime.now(tz.local);

    final today7PM = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      19,
    );

    final firstTrigger =
    now.isAfter(today7PM) ? now : today7PM;

    for (int i = 0; i < 10; i++) {
      final scheduledTime =
      firstTrigger.add(const Duration(minutes: 30) * i);

      if (scheduledTime.day != now.day) break;

      await _notifications.zonedSchedule(
        100 + i,
        'Time to journal',
        'Take 2 minutes to reflect on your day',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'journal_reminders',
            'Journal Reminders',
            channelDescription: 'Daily journaling reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
