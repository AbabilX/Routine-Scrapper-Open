import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/model/class_reminder.dart';
import '../domain/reminder_rules.dart';

class ClassReminderScheduler {
  ClassReminderScheduler(this._plugin);

  static const _channelId = 'class_reminders';
  static const _channelName = 'Class reminders';

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<ClassReminderScheduler> create() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    }

    final plugin = FlutterLocalNotificationsPlugin();
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
        macOS: darwin,
      ),
    );
    return ClassReminderScheduler(plugin);
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final allowed = await android.requestNotificationsPermission();
      if (allowed == false) return false;
      final canExact = await android.canScheduleExactNotifications();
      if (canExact != true) {
        await android.requestExactAlarmsPermission();
      }
      return true;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  Future<void> sync(List<ClassReminder> reminders) async {
    await _plugin.cancelAll();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final exact = await android?.canScheduleExactNotifications() ?? false;
    final mode = exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (final reminder in reminders) {
      await _schedule(reminder, mode);
    }
  }

  Future<void> _schedule(
    ClassReminder reminder,
    AndroidScheduleMode mode,
  ) async {
    final clock = ReminderRules.fireClock(
      reminder.start,
      reminder.minutesBefore,
    );
    final when = _nextWeekly(
      ReminderRules.dateTimeWeekday(reminder.routineDay),
      clock.hour,
      clock.minute,
    );
    await _plugin.zonedSchedule(
      id: ReminderRules.notificationId(reminder.id),
      title: '${reminder.course} — ${reminder.minutesBefore} মিনিট বাকি',
      body:
          '${reminder.room}  ·  ${reminder.start} – ${reminder.end}  ·  ${reminder.group}',
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Class start reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: mode,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: reminder.id,
    );
  }

  tz.TZDateTime _nextWeekly(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }
}
