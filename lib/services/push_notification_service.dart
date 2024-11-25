import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smart_parking/services/local_notification_service.dart';
import 'package:logger/logger.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Logger logger = Logger();

  Future<void> initialize() async {
    logger.i('--- Initializing PushNotificationService ---');

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('--- User granted permission ---');
      String? token = await _fcm.getToken();
      logger.i('--- FCM Token: $token ---');
    } else {
      logger.w('--- User declined or has not accepted permission ---');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i('--- Received a message while in the foreground ---');
      logger.d('Message data: ${message.data}');

      if (message.notification != null) {
        logger.i('--- Message also contained a notification ---');
        LocalNotificationService().showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.i('--- Message clicked! ---');
    });

    logger.i('--- PushNotificationService initialized successfully ---');
  }

  Future<String?> getToken() async {
    logger.i('--- Fetching FCM Token ---');
    final token = await _fcm.getToken();
    logger.i('--- FCM Token: $token ---');
    return token;
  }

  void subscribeToTopic(String topic) {
    logger.i('--- Subscribing to topic: $topic ---');
    _fcm.subscribeToTopic(topic);
  }

  void unsubscribeFromTopic(String topic) {
    logger.i('--- Unsubscribing from topic: $topic ---');
    _fcm.unsubscribeFromTopic(topic);
  }
}
