import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_parking/models/parking_spot.dart';
import 'package:smart_parking/screens/views/parking_map_view/parking_grid.dart';
import 'package:smart_parking/services/api_service.dart';
import 'package:smart_parking/services/secure_storage_service.dart';
import 'package:smart_parking/screens/views/universal/reservations_section.dart';
import 'package:smart_parking/screens/views/universal/section_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  /// Pobiera token i dane o miejscach parkingowych
  Future<Map<String, dynamic>> _loadData() async {
    final secureStorage = GetIt.instance<SecureStorageService>();
    final token = await secureStorage.getToken();

    if (token == null) {
      throw Exception('No valid token found. Please log in.');
    }

    final parkingSpots = await ApiService.getParkingStatus();
    final reservations = await ApiService.fetchAllReservations();

    return {
      'token': token,
      'parkingSpots': parkingSpots,
      'reservations': reservations,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data available'));
        }

        final data = snapshot.data!;
        final parkingSpots = (data['parkingSpots'] as List<ParkingSpot>)
          ..sort((a, b) {
            final regex = RegExp(r'([A-Z]+)(\d+)');
            final matchA = regex.firstMatch(a.prettyId ?? '');
            final matchB = regex.firstMatch(b.prettyId ?? '');

            if (matchA == null || matchB == null) return 0;

            final sectionA = matchA.group(1)!;
            final sectionB = matchB.group(1)!;
            final numberA = int.parse(matchA.group(2)!);
            final numberB = int.parse(matchB.group(2)!);

            if (sectionA == sectionB) {
              return numberA.compareTo(numberB);
            } else {
              return sectionA.compareTo(sectionB);
            }
          });
        final reservations = data['reservations'];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: ParkingGrid(parkingSpots: parkingSpots),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ReservationsSection(reservations: reservations, forAll: true),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
