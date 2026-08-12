import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling background notification: ${message.messageId}");
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // 🔴 Fixed Enum
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notification Permission Granted ✅');
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    String? token = await _firebaseMessaging.getToken();
    debugPrint("FCM Device Token: $token");

    await _firebaseMessaging.subscribeToTopic('all_members');
    await _firebaseMessaging.subscribeToTopic('announcements');
    await _firebaseMessaging.subscribeToTopic('events');

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'acp_events_channel',
      'ACP Events & Announcements',
      description: 'Important announcements and alerts for ACP members',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }
}