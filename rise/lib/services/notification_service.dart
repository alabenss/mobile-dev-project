import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/habit_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'habit_reminders',
    'Habit Reminders',
    description: 'Notifications for habit reminders',
    importance: Importance.max,
  );

  bool _initialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;
  void Function(String? screen)? _onTapAction;

  Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
    required void Function(String? screen) onTapAction,
  }) async {
    if (_initialized) return;

    _navigatorKey = navigatorKey;
    _onTapAction = onTapAction;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleLocalNotificationTap(response);
      },
    );

    // Create notification channel for Android
    final androidPlatform = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlatform?.createNotificationChannel(_channel);

    // Request Firebase permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle notification tap when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleFirebaseNotificationTap(message);
    });

    // Handle notification tap when app is opened from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleFirebaseNotificationTap(initialMessage);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final n = message.notification;
      if (n == null) return;

      await _local.show(
        n.hashCode,
        n.title,
        n.body,
        _getNotificationDetails(),
        payload: message.data['screen'] ?? message.data['habitKey'],
      );
    });

    // Get and print FCM token
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM TOKEN: $token');

    // Subscribe to demo topic
    await FirebaseMessaging.instance.subscribeToTopic('demo');

    _initialized = true;
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    print('Local notification tapped with payload: $payload');
    if (_onTapAction != null && payload != null) {
      _onTapAction!(payload);
    }
  }

  /// Handle Firebase notification tap
  void _handleFirebaseNotificationTap(RemoteMessage message) {
    final screen = message.data['screen'];
    final habitKey = message.data['habitKey'];
    print('Firebase notification tapped - screen: $screen, habitKey: $habitKey');
    
    if (_onTapAction != null) {
      _onTapAction!(screen ?? habitKey);
    }
  }

  /// Get notification details for local notifications
  NotificationDetails _getNotificationDetails() {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Schedule a habit reminder
  Future<void> scheduleHabitReminder(Habit habit, int userId) async {
    if (!habit.reminder || habit.time == null) return;

    final notificationId = _generateNotificationId(habit, userId);
    final scheduledTime = _getNextScheduledTime(habit);

    await _local.zonedSchedule(
      notificationId,
      'Time for ${habit.title}! 🎯',
      'Complete your habit and earn ${habit.points} points ⭐',
      scheduledTime,
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _getDateTimeComponents(habit.frequency),
      payload: habit.habitKey,
    );

    print('Scheduled notification for ${habit.title} at $scheduledTime');
  }

  /// Get next scheduled time for habit
  tz.TZDateTime _getNextScheduledTime(Habit habit) {
    final now = tz.TZDateTime.now(tz.local);
    final time = habit.time!;

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has passed today, schedule for tomorrow (or next occurrence)
    if (scheduledDate.isBefore(now)) {
      switch (habit.frequency.toLowerCase()) {
        case 'daily':
          scheduledDate = scheduledDate.add(const Duration(days: 1));
          break;
        case 'weekly':
          scheduledDate = scheduledDate.add(const Duration(days: 7));
          break;
        case 'monthly':
          scheduledDate = tz.TZDateTime(
            tz.local,
            now.month == 12 ? now.year + 1 : now.year,
            now.month == 12 ? 1 : now.month + 1,
            scheduledDate.day,
            time.hour,
            time.minute,
          );
          break;
        default:
          scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    return scheduledDate;
  }

  /// Get date time components for recurring notifications
  DateTimeComponents? _getDateTimeComponents(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return DateTimeComponents.time;
      case 'weekly':
        return DateTimeComponents.dayOfWeekAndTime;
      case 'monthly':
        return DateTimeComponents.dayOfMonthAndTime;
      default:
        return DateTimeComponents.time;
    }
  }

  /// Generate unique notification ID for habit
  int _generateNotificationId(Habit habit, int userId) {
    return '${userId}_${habit.habitKey}_${habit.frequency}'.hashCode;
  }

  /// Cancel habit reminder
  Future<void> cancelHabitReminder(Habit habit, int userId) async {
    final notificationId = _generateNotificationId(habit, userId);
    await _local.cancel(notificationId);
    print('Cancelled notification for ${habit.title}');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _local.cancelAll();
    print('Cancelled all notifications');
  }

  /// Show test notification (for testing, no Firebase needed)
  Future<void> showTestNotification({
    required String title,
    required String body,
    required String screen,
  }) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      _getNotificationDetails(),
      payload: screen,
    );
  }

  /// Show immediate notification
  Future<void> showImmediateNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      _getNotificationDetails(),
      payload: payload,
    );
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _local.pendingNotificationRequests();
  }

  /// Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}