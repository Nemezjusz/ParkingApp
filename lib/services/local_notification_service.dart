import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

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
    // Tutaj można obsłużyć kliknięcie powiadomienia
  }

  Future<void> showCustomNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    logger.i('--- Showing custom notification ---');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'parking_channel',
      'Parking Notifications',
      channelDescription: 'Notification about parking spot changes',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    logger.i('--- Custom notification displayed successfully ---');
  }
}
