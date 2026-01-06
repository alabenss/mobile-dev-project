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

    // Initialize timezone data and set local location
    tz.initializeTimeZones();
    // Set to local timezone - this is crucial for correct notification timing
    final locationName = tz.local.name;

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

    final androidPlatform = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlatform?.createNotificationChannel(_channel);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleFirebaseNotificationTap(message);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleFirebaseNotificationTap(initialMessage);
    }

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

    final token = await FirebaseMessaging.instance.getToken();

    await FirebaseMessaging.instance.subscribeToTopic('demo');

    _initialized = true;
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (_onTapAction != null && payload != null) {
      _onTapAction!(payload);
    }
  }

  void _handleFirebaseNotificationTap(RemoteMessage message) {
    final screen = message.data['screen'];
    final habitKey = message.data['habitKey'];
    
    if (_onTapAction != null) {
      _onTapAction!(screen ?? habitKey);
    }
  }

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

  /// Schedule a habit reminder - FIXED to use local time correctly
  Future<void> scheduleHabitReminder(Habit habit, int userId) async {
    if (!habit.reminder || habit.time == null) return;

    final notificationId = _generateNotificationId(habit, userId);
    final scheduledTime = _getNextScheduledTime(habit);


    // Get notification title based on habit type
    String notificationTitle;
    String notificationBody;
    
    if (habit.habitType == 'bad') {
      notificationTitle = 'Resist ${habit.title}! 💪';
      notificationBody = 'Skip this habit and earn ${habit.points} points ⭐';
    } else {
      notificationTitle = 'Time for ${habit.title}! 🎯';
      notificationBody = 'Complete your habit and earn ${habit.points} points ⭐';
    }
    
    // Add task/habit indicator
    if (habit.isTask) {
      notificationBody += '\nTask Progress: ${habit.taskCompletionCount}/10';
    } else {
      notificationBody += '\nStreak: ${habit.streakCount} 🔥';
    }

    await _local.zonedSchedule(
      notificationId,
      notificationTitle,
      notificationBody,
      scheduledTime,
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _getDateTimeComponents(habit.frequency),
      payload: habit.habitKey,
    );

  }

  /// Get next scheduled time - FIXED to properly use local timezone
  tz.TZDateTime _getNextScheduledTime(Habit habit) {
    // Get current time in local timezone
    final now = tz.TZDateTime.now(tz.local);
    final time = habit.time!;


    // Create scheduled time for today in LOCAL timezone
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      0,
      0,
    );


    // If the time has already passed today, schedule for the next occurrence
    if (scheduledDate.isBefore(now)) {
      
      switch (habit.frequency.toLowerCase()) {
        case 'daily':
          // Schedule for tomorrow at the same time
          scheduledDate = scheduledDate.add(const Duration(days: 1));
          break;
          
        case 'weekly':
          // Schedule for next week same day
          scheduledDate = scheduledDate.add(const Duration(days: 7));
          break;
          
        case 'monthly':
          // Schedule for same day next month
          int nextMonth = scheduledDate.month + 1;
          int nextYear = scheduledDate.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }
          
          // Handle edge case where day doesn't exist in next month (e.g., Jan 31 -> Feb)
          int nextDay = scheduledDate.day;
          final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
          if (nextDay > daysInNextMonth) {
            nextDay = daysInNextMonth;
          }
          
          scheduledDate = tz.TZDateTime(
            tz.local,
            nextYear,
            nextMonth,
            nextDay,
            time.hour,
            time.minute,
            0,
            0,
          );
          break;
          
        default:
          // Default to daily
          scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    return scheduledDate;
  }

  /// Get date time components for recurring notifications
  DateTimeComponents? _getDateTimeComponents(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return DateTimeComponents.time; // Repeat at same time every day
      case 'weekly':
        return DateTimeComponents.dayOfWeekAndTime; // Repeat same day of week
      case 'monthly':
        return DateTimeComponents.dayOfMonthAndTime; // Repeat same day of month
      default:
        return DateTimeComponents.time;
    }
  }

  /// Generate unique notification ID for habit
  int _generateNotificationId(Habit habit, int userId) {
    // Use a consistent hash that includes userId, habitKey, and frequency
    final uniqueString = '${userId}_${habit.habitKey}_${habit.frequency}';
    return uniqueString.hashCode;
  }

  /// Cancel habit reminder
  Future<void> cancelHabitReminder(Habit habit, int userId) async {
    final notificationId = _generateNotificationId(habit, userId);
    await _local.cancel(notificationId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _local.cancelAll();
  }

  /// Show test notification
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
  }

  /// Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}