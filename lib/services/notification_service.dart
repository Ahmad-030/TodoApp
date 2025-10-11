import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/todo_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await requestPermissions();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );
  }

  static Future<void> requestPermissions() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  static void onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  // Schedule EXACT TIME alarm notification (not 1 day before)
  static Future<void> scheduleNotification(Todo todo) async {
    if (todo.notificationId != null) {
      await cancelNotification(todo.notificationId!);
    }

    // Create exact due date/time
    final dueDateTime = DateTime(
      todo.dueDate.year,
      todo.dueDate.month,
      todo.dueDate.day,
      todo.dueTime.hour,
      todo.dueTime.minute,
    );

    final scheduledTime = tz.TZDateTime.from(dueDateTime, tz.local);

    // Only schedule if in the future
    if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
      // ALARM-STYLE notification with custom sound
      const androidDetails = AndroidNotificationDetails(
        'todo_alarms',
        'Task Alarms',
        channelDescription: 'Alarm notifications for tasks',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF2196F3),
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('alarm'), // Custom alarm sound
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        ticker: 'Task Due Now!',
        autoCancel: false,
        ongoing: true,
        timeoutAfter: 60000, // Auto dismiss after 1 minute
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alarm.mp3',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        todo.notificationId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '⏰ TASK DUE NOW!',
        '${todo.title}\n${todo.description.isNotEmpty ? todo.description : "Complete this task now!"}',
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: todo.id,
      );

      // Schedule 1 hour reminder as well
      final reminderTime = scheduledTime.subtract(const Duration(hours: 1));
      if (reminderTime.isAfter(tz.TZDateTime.now(tz.local))) {
        await _notifications.zonedSchedule(
          (todo.notificationId ?? 0) + 1,
          '🔔 Upcoming Task',
          '${todo.title} - Due in 1 hour',
          reminderTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'todo_reminders',
              'Task Reminders',
              importance: Importance.high,
              priority: Priority.high,
              enableVibration: true,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: todo.id,
        );
      }
    }
  }

  static Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'todo_alerts',
      'Todo Alerts',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    await _notifications.cancel(id + 1); // Cancel reminder too
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}