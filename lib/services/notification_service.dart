import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/todo_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permissions first
    await requestPermissions();

    // Android settings with alarm channel
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

    // Create notification channels with custom sound
    await _createNotificationChannels();
  }

  static Future<void> _createNotificationChannels() async {
    // High priority alarm channel with CUSTOM SOUND
    const alarmChannel = AndroidNotificationChannel(
      'todo_alarms',
      'Task Alarms',
      description: 'Alarm notifications for tasks',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'), // Your mp3 file (without .mp3 extension)
      enableVibration: true,
      enableLights: true,
    );

    // Regular reminder channel
    const reminderChannel = AndroidNotificationChannel(
      'todo_reminders',
      'Task Reminders',
      description: 'Reminder notifications for upcoming tasks',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Alert channel for tests
    const alertChannel = AndroidNotificationChannel(
      'todo_alerts',
      'Todo Alerts',
      description: 'General alerts and notifications',
      importance: Importance.high,
      playSound: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(alarmChannel);
      await androidPlugin.createNotificationChannel(reminderChannel);
      await androidPlugin.createNotificationChannel(alertChannel);
      print('✅ Notification channels created with custom alarm sound');
    }
  }

  static Future<void> requestPermissions() async {
    // Request notification permission
    final notificationStatus = await Permission.notification.request();
    print('Notification permission: $notificationStatus');

    // Request exact alarm permission (Android 12+)
    final alarmStatus = await Permission.scheduleExactAlarm.request();
    print('Exact alarm permission: $alarmStatus');

    // Check if we have the permissions
    if (!notificationStatus.isGranted) {
      print('⚠️ Notification permission not granted!');
    }
    if (!alarmStatus.isGranted) {
      print('⚠️ Exact alarm permission not granted!');
    }
  }

  static void onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  // Schedule EXACT TIME alarm notification with CUSTOM SOUND
  static Future<void> scheduleNotification(Todo todo) async {
    if (todo.notificationId == null) {
      print('⚠️ No notification ID for todo: ${todo.title}');
      return;
    }

    // Cancel any existing notifications for this task
    await cancelNotification(todo.notificationId!);

    // Create exact due date/time
    final dueDateTime = DateTime(
      todo.dueDate.year,
      todo.dueDate.month,
      todo.dueDate.day,
      todo.dueTime.hour,
      todo.dueTime.minute,
      0, // seconds
      0, // milliseconds
    );

    // Convert to TZDateTime using local timezone
    final scheduledTime = tz.TZDateTime.from(dueDateTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    print('📅 Scheduling alarm for: ${todo.title}');
    print('⏰ Due time: $scheduledTime');
    print('🕐 Current time: $now');
    print('⏳ Time difference: ${scheduledTime.difference(now).inMinutes} minutes');
    print('⏳ Time difference: ${scheduledTime.difference(now).inSeconds} seconds');

    // Only schedule if in the future (at least 1 second ahead)
    if (scheduledTime.isAfter(now.add(const Duration(seconds: 1)))) {
      // MAIN ALARM at exact due time with CUSTOM SOUND
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
        ticker: '⏰ Task Due Now!',
        autoCancel: false,
        ongoing: false,
        timeoutAfter: 300000, // Auto dismiss after 5 minutes
        channelShowBadge: true,
        showWhen: true,
        ledColor: Color(0xFF2196F3),
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alarm.mp3', // For iOS
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      try {
        await _notifications.zonedSchedule(
          todo.notificationId!,
          '⏰ TASK DUE NOW!',
          '${todo.title}\n${todo.description.isNotEmpty ? todo.description : "Complete this task now!"}',
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: todo.id,
        );
        print('✅ Main alarm scheduled successfully for ID: ${todo.notificationId}');
        print('🔊 Custom alarm sound will play: alarm.mp3');

        // Immediately verify it was scheduled
        final pending = await _notifications.pendingNotificationRequests();
        final mainAlarm = pending.where((p) => p.id == todo.notificationId).firstOrNull;
        if (mainAlarm != null) {
          print('✅ VERIFIED: Main alarm is in pending list');
        } else {
          print('❌ WARNING: Main alarm NOT in pending list!');
        }
      } catch (e) {
        print('❌ Error scheduling main alarm: $e');
        print('❌ Stack trace: ${StackTrace.current}');
      }

      // Schedule 1 hour early reminder (only if more than 1 hour away)
      final reminderTime = scheduledTime.subtract(const Duration(hours: 1));
      if (reminderTime.isAfter(now.add(const Duration(seconds: 1)))) {
        const reminderDetails = AndroidNotificationDetails(
          'todo_reminders',
          'Task Reminders',
          channelDescription: 'Reminder notifications for upcoming tasks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF2196F3),
          enableVibration: true,
          playSound: true,
        );

        const reminderIosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const reminderNotification = NotificationDetails(
          android: reminderDetails,
          iOS: reminderIosDetails,
        );

        try {
          await _notifications.zonedSchedule(
            todo.notificationId! + 1,
            '🔔 Upcoming Task',
            '${todo.title} - Due in 1 hour',
            reminderTime,
            reminderNotification,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: todo.id,
          );
          print('✅ Reminder alarm scheduled successfully for ID: ${todo.notificationId! + 1}');
        } catch (e) {
          print('❌ Error scheduling reminder: $e');
        }
      } else {
        print('⏭️ Skipping reminder - task is less than 1 hour away');
      }

      // Final verification of all pending alarms
      final allPending = await _notifications.pendingNotificationRequests();
      print('📋 Total pending notifications: ${allPending.length}');
      for (var p in allPending) {
        print('  - ID: ${p.id}, Title: ${p.title}, Body: ${p.body}');
      }
    } else {
      print('⚠️ Cannot schedule alarm in the past!');
      print('⚠️ Scheduled time: $scheduledTime');
      print('⚠️ Current time: $now');
      print('⚠️ Difference: ${scheduledTime.difference(now).inSeconds} seconds');
    }
  }

  static Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'todo_alarms', // Use alarm channel for test
      'Task Alarms',
      channelDescription: 'Alarm notifications for tasks',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'), // Custom sound
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2196F3),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm.mp3',
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
      );
      print('✅ Test alarm sent with custom sound!');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    await _notifications.cancel(id + 1); // Cancel reminder too
    print('🗑️ Cancelled notifications for ID: $id');
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🗑️ All notifications cancelled');
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}