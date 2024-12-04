import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parking/navigation/app_router_paths.dart';
import 'package:smart_parking/widgets/settings_tile.dart';
import 'package:smart_parking/constants/constants.dart';
import 'package:smart_parking/services/secure_storage_service.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:smart_parking/screens/change_password_screen.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SecureStorageService _secureStorage = SecureStorageService();

  String fullName = 'Guest';
  String email = 'Not available';

  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadThemePreference();
  }

  Future<void> _loadUserData() async {
    final token = await _secureStorage.getToken();

    if (token != null && JwtDecoder.isExpired(token) == false) {
      final decodedToken = JwtDecoder.decode(token);
      setState(() {
        fullName = decodedToken['full_name'] ?? 'Guest';
        email = decodedToken['email'] ?? 'Not available';
      });
    } else {
      setState(() {
        fullName = 'Guest';
        email = 'Not available';
      });
    }
  }

  Future<void> _loadThemePreference() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      isDarkMode = savedThemeMode == AdaptiveThemeMode.dark;
    });
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
      if (value) {
        AdaptiveTheme.of(context).setDark();
      } else {
        AdaptiveTheme.of(context).setLight();
      }
    });
  }

  Future<void> _logout() async {
  await _secureStorage.clearToken();

  // Nawigacja za pomocą GoRouter
  if (context.mounted) {
    context.go(AppRouterPaths.login);
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profil użytkownika
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.primaryColor,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Wyświetlenie imienia i nazwiska
                    Text(
                      fullName,
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Wyświetlenie adresu e-mail
                    Text(
                      email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey),

              // Sekcja ustawień
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(
                        'App Theme',
                        style: textTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        'Switch between Light and Dark theme',
                        style: textTheme.bodyMedium?.copyWith(
                          color: textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      value: isDarkMode,
                      onChanged: _toggleDarkMode,
                      secondary: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: theme.primaryColor,
                      ),
                    ),
                    const NotificationsSwitch(),
                    SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      subtitle: 'Update your password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey),

              // Sekcja wylogowania
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SettingsTile(
                  icon: Icons.exit_to_app,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: _logout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget do zarządzania powiadomieniami
class NotificationsSwitch extends StatefulWidget {
  const NotificationsSwitch({super.key});

  @override
  _NotificationsSwitchState createState() => _NotificationsSwitchState();
}

class _NotificationsSwitchState extends State<NotificationsSwitch> {
  bool _isSubscribed = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSubscribed = prefs.getBool('isSubscribed') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _isSubscribed = value;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSubscribed', value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile(
      title: Text(
        'Notifications',
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        'Enable or disable notifications',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
        ),
      ),
      value: _isSubscribed,
      onChanged: _toggleNotifications,
      secondary: Icon(
        Icons.notifications,
        color: theme.primaryColor,
      ),
    );
  }
}
