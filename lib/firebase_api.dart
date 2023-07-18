import 'dart:convert';

import 'package:fcmfluttertest/home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

class FirebaseApi {
  final _firebaseMessageing = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notifications',
      description: 'This channel used for importance notification',
      importance: Importance.defaultImportance);

  final _localNotification = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await _firebaseMessageing.requestPermission();

    final fCMTokenData = await _firebaseMessageing.getToken();

    print('firebase fcm token is ===*\n  $fCMTokenData \n*==');

    FirebaseMessaging.onBackgroundMessage(/*(message) => null*/
        handleBackgroundMessage);

    initPshNotifications();
    initLocalNotifications();
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Title: ${message.notification?.title} \n');
    print('Body: ${message.notification?.body} \n');
    print('Payload: ${message.data}');
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(HomeScreen.route, arguments: message);
  }

  Future initPshNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;

      if (notification == null) return;
      _localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                  _androidChannel.id, _androidChannel.name,
                  channelDescription: _androidChannel.description,
                  icon: '@drawable/logo')),
          payload: jsonEncode(message.toMap()));
    });
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/logo');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotification.initialize(settings,
        onDidReceiveNotificationResponse: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload.toString()));
      handleMessage(message);
    });

    final platform = _localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }
}
