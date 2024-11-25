import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/parking_spot_bloc.dart';
import 'package:smart_parking/models/parking_spot.dart';
import 'package:smart_parking/screens/profile_screen.dart';
import 'package:smart_parking/screens/reservation_screen.dart';
import 'package:smart_parking/widgets/custom_app_bar.dart';
import 'package:smart_parking/widgets/custom_title.dart';
import 'package:smart_parking/widgets/your_reservations_section.dart';
import '../widgets/parking_spot_tile.dart';
import 'package:smart_parking/constants/constants.dart';

class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({Key? key}) : super(key: key);

  @override
  _ParkingMapScreenState createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    final token = 'YOUR_TOKEN_HERE'; // Replace with actual token

    _screens = [
      BlocProvider<ParkingSpotBloc>(
        create: (context) {
          final bloc = ParkingSpotBloc(token: token);
          bloc.add(FetchParkingSpots());
          return bloc;
        },
        child: ParkingMapView(),
      ),
      ReservationScreen(),
      ProfileScreen(),
    ];
  }

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

// Parking map view screen
class ParkingMapView extends StatelessWidget {
  const ParkingMapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color parkingSpotAvailable = Colors.green;
    const Color parkingSpotReserved = Colors.yellow;
    const Color parkingSpotOccupied = Colors.red;

    return Column(
      children: [
        CustomTitle(icon: Icons.map, title: 'Company Parking Map'),
        Expanded(
          flex: 2,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: BlocBuilder<ParkingSpotBloc, ParkingSpotState>(
              builder: (context, state) {
                if (state is ParkingSpotLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ParkingSpotLoaded) {
                  final parkingSpots = state.parkingSpots;
                  return AspectRatio(
                    aspectRatio: 5 / 6,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 5,
                      ),
                      itemCount: parkingSpots.length,
                      itemBuilder: (context, index) {
                        final spot = parkingSpots[index];
                        String spotId = spot.prettyId ?? 'Spot ${index + 1}';
                        Color spotColor;
                        if (spot.status == 'free') {
                          spotColor = parkingSpotAvailable;
                        } else if (spot.status == 'reserved') {
                          spotColor = parkingSpotReserved;
                        } else if (spot.status == 'occupied') {
                          spotColor = parkingSpotOccupied;
                        } else {
                          spotColor = Colors.grey;
                        }
                        return ParkingSpotTile(id: spotId, color: spotColor);
                      },
                    ),
                  );
                } else if (state is ParkingSpotError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ),
        YourReservationsSection(),
      ],
    );
  }
}
