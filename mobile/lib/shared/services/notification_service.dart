import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level handler for background/terminated messages (required by FCM).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are shown automatically by FCM on Android.
  // On iOS the system handles them. Nothing extra needed here.
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'familysynch_default',
    'FamilySync Notifications',
    description: 'Task assignments, calendar reminders, and feed updates.',
    importance: Importance.high,
  );

  /// Call once from main() after Firebase.initializeApp().
  Future<void> init() async {
    // Register background handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission (iOS / web).
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android: create notification channel.
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    // Initialise flutter_local_notifications.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    // Show local notification when app is in foreground.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // iOS: show foreground notifications.
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Returns the FCM registration token, or null if unavailable.
  Future<String?> getToken() => _fcm.getToken();

  /// Stream that fires when the token is refreshed.
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  /// Stream of messages that opened the app from background.
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// The message that launched the app from terminated state, if any.
  Future<RemoteMessage?> get initialMessage => _fcm.getInitialMessage();

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
