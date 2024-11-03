import 'package:flutter/material.dart';
import 'package:smart_parking/constants/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:smart_parking/blocs/auth_state.dart';
import 'package:smart_parking/blocs/auth_event.dart';
import 'package:smart_parking/screens/change_password_screen.dart';
import 'package:smart_parking/screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String username = 'Guest';
    String email = 'Not available';

    if (authState.isAuthenticated && authState.token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(authState.token!);
      username = decodedToken['sub']; // Zakładamy, że 'sub' zawiera nazwę użytkownika
      // Jeśli email jest w tokenie, możesz go również pobrać
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nagłówek ustawień użytkownika bez zdjęcia profilowego
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            // Sekcja ustawień ogólnych
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {
                      // Logika zmiany języka
                    },
                  ),
                  SettingsTile.switchTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Enable Dark Mode',
                    value: false,
                    onChanged: (bool value) {
                      // Logika przełączania trybu ciemnego
                    },
                  ),
                  SettingsTile.switchTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Allow Notifications',
                    value: true,
                    onChanged: (bool value) {
                      // Logika powiadomień
                    },
                  ),
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
    );
  }
}

// Custom widget for each settings tile
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  static Widget switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}
