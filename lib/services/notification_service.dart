import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/todo_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permissions
    await requestPermissions();

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
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
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static void onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  // Schedule notification for 1 day before due date
  static Future<void> scheduleNotification(Todo todo) async {
    // Cancel any existing notification
    if (todo.notificationId != null) {
      await cancelNotification(todo.notificationId!);
    }

    // Calculate notification time (1 day before due date at 9 AM)
    final scheduledDate = tz.TZDateTime.from(
      todo.dueDate.subtract(const Duration(days: 1)),
      tz.local,
    );

    final scheduledTime = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9, // 9 AM
      0,
    );

    // Only schedule if the time is in the future
    if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
      const androidDetails = AndroidNotificationDetails(
        'todo_reminders',
        'Todo Reminders',
        channelDescription: 'Reminders for upcoming todos',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF673AB7),
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // FIXED: Removed uiLocalNotificationDateInterpretation parameter
      await _notifications.zonedSchedule(
        todo.notificationId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '🔔 Reminder: ${todo.title}',
        'Due tomorrow! ${todo.description.isNotEmpty ? todo.description : "Don\'t forget!"}',
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: todo.id,
      );
    }
  }

  // Show immediate notification
  static Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'todo_alerts',
      'Todo Alerts',
      channelDescription: 'Immediate alerts for todos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}