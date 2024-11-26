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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String username = 'Guest';
    String email = 'Not available';

    if (authState.isAuthenticated && authState.token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(authState.token!);
      username = decodedToken['sub'];
      email = decodedToken['email'] ?? 'Not available';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[400],
                          ),
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

    PushNotificationService pushService = PushNotificationService();
    if (value) {
      pushService.subscribeToTopic('all');
    } else {
      pushService.unsubscribeFromTopic('all');
    }
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
