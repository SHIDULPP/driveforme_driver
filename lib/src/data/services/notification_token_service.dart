import 'dart:convert';
import 'dart:developer';

import 'package:driveforme_driver/firebase_options.dart';
import 'package:driveforme_driver/src/data/apis/notification_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kTripChannelId = 'driveforme_trips';
const _kTripChannelName = 'Trip updates';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log(
    'Background FCM: ${message.messageId} ${message.notification?.title}',
    name: 'PushNotification',
  );
}

class PushNotificationService {
  PushNotificationService(this._notificationApi);

  final NotificationApi _notificationApi;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    const androidChannel = AndroidNotificationChannel(
      _kTripChannelId,
      _kTripChannelName,
      description: 'Driver trip alerts',
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if (title == null && body == null) return;

    await _local.show(
      notification.hashCode,
      title ?? 'Drive For Me',
      body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _kTripChannelId,
          _kTripChannelName,
          channelDescription: 'Driver trip alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      log('FCM getToken failed: $e', name: 'PushNotification');
      return null;
    }
  }

  Future<void> registerTokenWithBackend() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return;
    final response = await _notificationApi.registerFcmToken(token);
    if (!response.success) {
      log(
        'Failed to register FCM token: ${response.message}',
        name: 'PushNotification',
      );
    }
  }

  void listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      if (token.isEmpty) return;
      await _notificationApi.registerFcmToken(token);
    });
  }
}

class NotificationTokenService {
  NotificationTokenService(this._push);

  final PushNotificationService _push;

  Future<void> registerTokenIfAvailable() async {
    try {
      await _push.initialize();
      _push.listenForTokenRefresh();
      await _push.registerTokenWithBackend();
    } catch (e) {
      log('FCM registration skipped: $e', name: 'NotificationTokenService');
    }
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService(ref.watch(notificationApiProvider));
});

final notificationTokenServiceProvider =
    Provider<NotificationTokenService>((ref) {
  return NotificationTokenService(ref.watch(pushNotificationServiceProvider));
});
