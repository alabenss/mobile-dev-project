import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import '../models/habit_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize Firebase Cloud Messaging
    await _initializeFCM();

    _initialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // iOS permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Android 13+ permissions are handled in AndroidManifest.xml
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    // Get FCM token
    String? token = await _fcm.getToken();
    print('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification taps when app is terminated
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Show local notification when app is in foreground
    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      _getNotificationDetails(),
      payload: message.data['habitKey'],
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final habitKey = message.data['habitKey'];
    print('Notification tapped for habit: $habitKey');
    // Navigate to habits screen or specific habit
    // You can use a global navigator key or stream controller
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final habitKey = response.payload;
    print('Local notification tapped for habit: $habitKey');
    // Navigate to habits screen or specific habit
  }

  /// Get notification details for local notifications
  NotificationDetails _getNotificationDetails() {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Notifications for habit reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

/// Schedule a habit reminder
Future<void> scheduleHabitReminder(Habit habit, int userId) async {
  if (!habit.reminder || habit.time == null) return;

  final notificationId = _generateNotificationId(habit, userId);
  final scheduledTime = _getNextScheduledTime(habit);

  await _localNotifications.zonedSchedule(
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
    await _localNotifications.cancel(notificationId);
    print('Cancelled notification for ${habit.title}');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('Cancelled all notifications');
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification(String title, String body,
      {String? payload}) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      _getNotificationDetails(),
      payload: payload,
    );
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  /// Send notification to specific user (requires backend)
  /// This is just a placeholder - actual implementation needs a backend
  Future<void> sendNotificationToUser(
      String userId, String title, String body) async {
    // This would typically be done through your backend
    // Backend would use Firebase Admin SDK to send the notification
    print('Sending notification to user: $userId');
  }
}