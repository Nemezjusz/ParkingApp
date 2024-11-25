import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _instance;
  }

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Logger logger = Logger();

  Future<void> initialize() async {
    logger.i('--- Initializing LocalNotificationService ---');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotification,
    );

    logger.i('--- LocalNotificationService initialized successfully ---');
  }

  void selectNotification(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    logger.i('--- Notification clicked with payload: $payload ---');
    // Dodaj logikę przekierowania użytkownika na określony ekran
  }

  Future<void> showNotification(RemoteMessage message) async {
    logger.i('--- Showing notification for message: ${message.messageId} ---');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // ID kanału
      'your_channel_name', // Nazwa kanału
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // ID powiadomienia
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );

    logger.i('--- Notification displayed successfully ---');
  }
}
