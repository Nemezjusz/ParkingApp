import 'package:flutter/material.dart';
import 'package:smart_parking/constants/constants.dart';
import 'package:smart_parking/screens/settings_screen.dart';
import 'package:smart_parking/widgets/custom_app_bar.dart';
import 'package:smart_parking/widgets/custom_title.dart';
import 'package:smart_parking/widgets/your_reservations_section.dart';
import 'reservation_screen.dart';
import '../widgets/parking_spot_tile.dart';

class ParkingMapScreen extends StatefulWidget {
  @override
  _ParkingMapScreenState createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  int _selectedIndex = 0;

  // Lista ekranów dla każdego indeksu w BottomNavigationBar
  final List<Widget> _screens = [
    ParkingMapView(),
    ReservationScreen(),
    SettingsScreen(), // Stwórz ekran ustawień lub dodaj placeholder
  ];

  // Funkcja zmieniająca indeks i ekran
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Smart Parking"), // Użyj nowego AppBar
      body: _screens[_selectedIndex], // Wyświetl odpowiedni ekran w zależności od indeksu
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: bottomNavBackground,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Reservation'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Używamy funkcji zmiany indeksu
      ),
    );
  }
}

// Ekran widoku mapy parkingowej (oryginalna zawartość ParkingMapScreen)
class ParkingMapView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTitle(icon: Icons.map, title: 'Company Parking Map'),
        Expanded(
          flex: 2,
          child: Container(
            color: sectionBackground,
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
