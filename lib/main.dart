import 'package:flutter/material.dart';
import 'package:smart_parking/blocs/app_theme.dart';
import 'package:smart_parking/navigation/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_parking/services/local_notification_service.dart';
import 'package:smart_parking/services/service_locator.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

final Logger logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Funkcja obsługująca wiadomości w tle z Firebase Cloud Messaging.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  logger.i('Handling a background message: ${message.messageId}');
}

/// Główna funkcja uruchamiająca aplikację.
/// Inicjalizuje Firebase, konfiguracje środowiskowe oraz usługi powiadomień.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfiguracja GetIt.
  setupServiceLocator();

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

  // Inicjalizacja lokalnych powiadomień.
  final localNotificationService = locator<LocalNotificationService>();
  await localNotificationService.initialize();

  runApp(const SmartParkingApp());
}

/// Główna klasa aplikacji.
/// Konfiguruje motywy, nawigację (GoRouter) oraz podstawowe ustawienia.
class SmartParkingApp extends StatelessWidget {
  const SmartParkingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp.router(
        routerDelegate: AppRouter.router.routerDelegate,
        routeInformationParser: AppRouter.router.routeInformationParser,
        routeInformationProvider: AppRouter.router.routeInformationProvider,
        title: 'Smart Parking',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
      ),
    );
  }
}
