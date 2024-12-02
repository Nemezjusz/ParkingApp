import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_parking/navigation/app_router_paths.dart';

class AuthGuard {
  final _storage = GetIt.I<FlutterSecureStorage>();

  /// Sprawdza, czy sesja użytkownika jest ważna.
  Future<bool> isSessionValid() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  /// Funkcja przekierowania dla chronionych tras.
  Future<String?> redirect(GoRouterState state) async {
    final isValid = await isSessionValid();
    if (!isValid && state.fullPath != AppRouterPaths.login) {
      return AppRouterPaths.login; // Przekierowanie do logowania.
    }
    return null; // Pozwól na dostęp do trasy.
  }

  /// Usunięcie sesji użytkownika.
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}
