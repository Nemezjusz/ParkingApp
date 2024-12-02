import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_parking/services/local_notification_service.dart';
import 'package:smart_parking/services/secure_storage_service.dart';

final GetIt locator = GetIt.instance;

/// Funkcja rejestrująca singletony w GetIt.
void setupServiceLocator() {
  // Rejestracja FlutterSecureStorage jako singleton.
  locator.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  locator.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  // Rejestracja LocalNotificationService jako singleton.
  locator.registerLazySingleton<LocalNotificationService>(() => LocalNotificationService());
}
