import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:smart_parking/blocs/auth_event.dart';
import 'package:smart_parking/blocs/theme_bloc.dart';
import 'package:smart_parking/screens/login_screen.dart';
import 'package:smart_parking/widgets/settings_tile.dart';
import 'package:smart_parking/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parking/services/push_notification_service.dart';
import 'package:smart_parking/screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = 'Guest';
  String email = 'Not available';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;

    if (authState.isAuthenticated && authState.token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(authState.token!);
      setState(() {
        fullName = decodedToken['full_name'] ?? 'Guest';
        email = decodedToken['email'] ?? 'Not available';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pobranie aktualnego motywu
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
                    SettingsTile.switchTileWidget(
                      context: context,
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      subtitle: 'Enable Dark Mode',
                      value: context.watch<ThemeBloc>().state.isDarkMode,
                      onChanged: (bool value) {
                        context.read<ThemeBloc>().add(ToggleTheme());
                      },
                    ),
                    NotificationsSwitch(),
                    SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      subtitle: 'Update your password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePasswordScreen()),
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
                  onTap: () {
                    context.read<AuthBloc>().add(LoggedOut());
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
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

    // PushNotificationService pushService = PushNotificationService();
    // if (value) {
    //   pushService.subscribeToTopic('all');
    // } else {
    //   pushService.unsubscribeFromTopic('all');
    // }
  }

  @override
  Widget build(BuildContext context) {

    return SettingsTile.switchTileWidget(
      context: context,
      icon: Icons.notifications,
      title: 'Notifications',
      subtitle: 'Allow Notifications',
      value: _isSubscribed,
      onChanged: _toggleNotifications,
    );
  }
}
