/// NotificationService — FCM token registration and push handling.

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:familysynch/shared/services/api_client.dart';

// Top-level handler for background/terminated messages (required by FCM).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are shown automatically by FCM on Android.
  // On iOS the system handles them. Nothing extra needed here.
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(apiClientProvider));
});

class NotificationService {
  static final NotificationService instance = NotificationService(ApiClient());

  final ApiClient _api;
  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'familysynch_default',
    'FamilySync Notifications',
    description: 'Task assignments, calendar reminders, and feed updates.',
    importance: Importance.high,
  );

  NotificationService(this._api);

  Future<void> init() => initialize();

  Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Android: create notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    // Initialize local notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    // iOS: show foreground notifications
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Register token
    final token = await _fcm.getToken();
    if (token != null) await registerToken(token);

    // Refresh handler
    _fcm.onTokenRefresh.listen(registerToken);

    // Foreground message handler — show local notification
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  Future<void> registerToken(String token) async {
    try {
      await _api.post('/notifications/register', body: {
        'fcm_token': token,
        'device_platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (_) {}
  }

  Future<void> unregisterToken() async {
    final token = await _fcm.getToken();
    if (token == null) return;
    try {
      await _api.delete('/notifications/register', body: {
        'fcm_token': token,
        'device_platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (_) {}
  }

  /// Returns the FCM registration token, or null if unavailable.
  Future<String?> getToken() => _fcm.getToken();

  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  /// Stream of messages that opened the app from background.
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// The message that launched the app from terminated state, if any.
  Future<RemoteMessage?> get initialMessage => _fcm.getInitialMessage();

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
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
      payload: message.data.toString(),
    );
  }
}
