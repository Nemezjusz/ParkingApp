import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_parking/screens/views/settings_view/settings_view.dart';
import 'package:smart_parking/screens/views/reservation_view/reservation_view.dart';
import 'package:smart_parking/screens/login_screen.dart';
import 'package:smart_parking/screens/views/parking_map_view/home_view.dart';
import 'package:smart_parking/widgets/custom_app_bar.dart';

class ViewsScreen extends StatefulWidget {
  const ViewsScreen({Key? key}) : super(key: key);

  @override
  _ViewsScreenState createState() => _ViewsScreenState();
}

class _ViewsScreenState extends State<ViewsScreen> {
  final FlutterSecureStorage _storage = GetIt.instance<FlutterSecureStorage>();
  int _selectedIndex = 0;

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  void _logout() async {
    await _storage.delete(key: 'auth_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const HomeView(),
      const ReservationView(),
      const SettingsView(),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: "Smart Parking",
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Reservation'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
