import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'demo_channel',
    'Demo Notifications',
    description: 'Rise notifications',
    importance: Importance.max,
  );

  Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
    required void Function(String? screen) onTapAction,
  }) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onTapAction(response.payload);
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
      onTapAction(message.data['screen']);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      onTapAction(initialMessage.data['screen']);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final n = message.notification;
      if (n == null) return;

      await _local.show(
        n.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: message.data['screen'], // "journal" or "home"
      );
    });

    final token = await FirebaseMessaging.instance.getToken();
    // ignore: avoid_print
    print('FCM TOKEN: $token');

    await FirebaseMessaging.instance.subscribeToTopic('demo');
  }

  // ✅ EASY instant test notification (no firebase needed)
  Future<void> showTestNotification({
    required String title,
    required String body,
    required String screen,
  }) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: screen,
    );
  }
}
