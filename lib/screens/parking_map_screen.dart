import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:smart_parking/blocs/auth_state.dart';
import 'package:smart_parking/blocs/parking_spot_bloc.dart';
import 'package:smart_parking/screens/login_screen.dart';
import 'package:smart_parking/screens/profile_screen.dart';
import 'package:smart_parking/screens/reservation_screen.dart';
import 'package:smart_parking/widgets/custom_app_bar.dart';
import 'package:smart_parking/widgets/custom_title.dart';
import 'package:smart_parking/widgets/reservations_section.dart';
import '../widgets/parking_spot_tile.dart';
import 'package:smart_parking/services/api_service.dart';

class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({Key? key}) : super(key: key);

  @override
  _ParkingMapScreenState createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  int _selectedIndex = 0;

  void refreshReservations() {
    setState(() {});
    context.read<ParkingSpotBloc>().add(FetchParkingSpots());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!authState.isAuthenticated || authState.token == null) {
          // Jeśli użytkownik nie jest uwierzytelniony, przekieruj na ekran logowania
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final String token = (authState as Authenticated).token!;

        final List<Widget> _screens = [
          BlocProvider<ParkingSpotBloc>(
            create: (context) =>
                ParkingSpotBloc(token: token)..add(FetchParkingSpots()),
            child: const ParkingMapView(),
          ),
          const ReservationScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          appBar: const CustomAppBar(title: "Smart Parking"),
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            selectedItemColor:
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor:
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.directions_car), label: 'Reservation'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}

class ParkingMapView extends StatelessWidget {
  const ParkingMapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color parkingSpotAvailable = Colors.green;
    const Color parkingSpotReserved = Colors.yellow;
    const Color parkingSpotOccupied = Colors.red;

    final authState = context.read<AuthBloc>().state;
    final String token = (authState as Authenticated).token!;

    return Column(
      children: [
        const CustomTitle(icon: Icons.map, title: 'Company Parking Map'),
        // Mapa parkingu - zawsze widoczna w całości
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: AspectRatio(
            aspectRatio: 5 / 6,
            child: BlocBuilder<ParkingSpotBloc, ParkingSpotState>(
              builder: (context, state) {
                if (state is ParkingSpotLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ParkingSpotLoaded) {
                  final parkingSpots = state.parkingSpots;

                  // Posortuj parkingSpots na podstawie prettyId
                  parkingSpots.sort((a, b) {
                    final regex = RegExp(r'([A-Za-z]+)(\d+)');
                    final matchA = regex.firstMatch(a.prettyId ?? '');
                    final matchB = regex.firstMatch(b.prettyId ?? '');

                    if (matchA != null && matchB != null) {
                      final letterA = matchA.group(1)!;
                      final numberA = int.tryParse(matchA.group(2)!) ?? 0;
                      final letterB = matchB.group(1)!;
                      final numberB = int.tryParse(matchB.group(2)!) ?? 0;

                      if (letterA == letterB) {
                        return numberA.compareTo(numberB);
                      } else {
                        return letterA.compareTo(letterB);
                      }
                    }
                    return 0;
                  });

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                      if (spot.status.toLowerCase() == 'free') {
                        spotColor = parkingSpotAvailable;
                      } else if (spot.status.toLowerCase() == 'reserved') {
                        spotColor = parkingSpotReserved;
                      } else if (spot.status.toLowerCase() == 'occupied') {
                        spotColor = parkingSpotOccupied;
                      } else {
                        spotColor = Colors.grey;
                      }
                      return ParkingSpotTile(id: spotId, color: spotColor);
                    },
                  );
                } else if (state is ParkingSpotError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: ReservationsSection(
              fetchReservations: () => ApiService.fetchAllReservations(token),
              title: 'All Reservations',
              icon: Icons.list,
              onRefresh: () {
                context.read<ParkingSpotBloc>().add(FetchParkingSpots());
              },
            ),
          ),
        ),
      ],
    );
  }
}
