import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;



// Handling of local notifications in the app.

class NotificationService{
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  //Initializing Notifs for Android

  static Future<void> init() async {
    //Initialize timezone for proper scheduling
    tzdata.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);


    /// Shows Notif immediately(for testting)
  }
    static Future<void> showInstant({
      required String title,
      required String body,
    }) async {
      const androidDetails = AndroidNotificationDetails(
        'instant_channel',
        'Instant Notification',
        channelDescription: 'Instant notifications for testing',
        importance: Importance.high,
        priority: Priority.high,
      );

      await _notifications.show(
        0,
        title,
        body,
        const NotificationDetails(android: androidDetails),
      );
    }

    //Schedule a daily notification at a specific time.

  static Future<void> scheduleDaily({
    required TimeOfDay time,
    String title = 'Life Goals Reminder',
    String body = 'Check your goals and habits today!',
}) async{
    final now = TimeOfDay.now();
    final nowDate = DateTime.now();

    // convert TimeofDay to a DateTime

    DateTime scheduled = DateTime(
      nowDate.year,
      nowDate.month,
      nowDate.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(nowDate)){
      scheduled =  scheduled.add(const Duration(days:1));
    }
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminders',
      channelDescription: 'Daily Habit and goal reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _notifications.zonedSchedule(
      time.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(android: androidDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

  }

  // Cancel all schedules notifications
static Future<void> cancelAll() async{
    await _notifications.cancelAll();
}
  }
