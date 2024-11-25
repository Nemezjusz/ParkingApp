import 'package:flutter/material.dart';
import 'package:smart_parking/screens/profile_screen.dart';
import 'package:smart_parking/screens/reservation_screen.dart';
import 'package:smart_parking/widgets/custom_app_bar.dart';
import 'package:smart_parking/widgets/custom_title.dart';
import 'package:smart_parking/widgets/your_reservations_section.dart';
import '../widgets/parking_spot_tile.dart';
import 'package:smart_parking/constants/constants.dart';

class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({super.key});

  @override
  _ParkingMapScreenState createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ParkingMapView(),
    ReservationScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Smart Parking"),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Reservation'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Ekran widoku mapy parkingowej
class ParkingMapView extends StatelessWidget {
  const ParkingMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTitle(icon: Icons.map, title: 'Company Parking Map'),
        Expanded(
          flex: 2,
          child: Container(
            color: Theme.of(context).colorScheme.surface, // Użyj motywu
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: AspectRatio(
              aspectRatio: 5 / 6,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 5,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  String spotId = 'Spot ${index + 1}';
                  Color spotColor = index % 3 == 0
                      ? parkingSpotAvailable
                      : (index % 3 == 1 ? parkingSpotReserved : parkingSpotOccupied);
                  return ParkingSpotTile(id: spotId, color: spotColor);
                },
              ),
            ),
          ),
        ),
        YourReservationsSection(),
      ],
    );
  }
}
