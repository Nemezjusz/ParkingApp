import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:smart_parking/blocs/theme_bloc.dart';
import 'package:smart_parking/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:smart_parking/services/push_notification_service.dart';
import 'package:smart_parking/services/local_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_parking/blocs/parking_spot_bloc.dart';

final Logger logger = Logger();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  logger.i('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    logger.i('🔵 API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
  } catch (e) {
    logger.e('🔴 Nie można załadować pliku .env: $e');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  PushNotificationService pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();

  LocalNotificationService localNotificationService =
      LocalNotificationService();
  await localNotificationService.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider<ParkingSpotBloc>(
          create: (context) =>
              ParkingSpotBloc(token: '')..add(FetchParkingSpots()),
        ),
      ],
      child: const SmartParkingApp(),
    ),
  );
}

class SmartParkingApp extends StatelessWidget {
  const SmartParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Smart Parking',
          debugShowCheckedModeBanner: false,
          theme: themeState.themeData,
          home: const LoginScreen(),
        );
      },
    );
  }
}
