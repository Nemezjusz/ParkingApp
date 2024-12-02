import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_parking/models/parking_spot.dart';
import 'package:smart_parking/models/reservation.dart';
import 'package:smart_parking/screens/views/parking_map_view/parking_grid.dart';
import 'package:smart_parking/services/api_service.dart';
import 'package:smart_parking/services/secure_storage_service.dart';
import 'package:smart_parking/screens/views/universal/reservations_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Timer _timer;
  List<Reservation> _reservations = [];
  List<ParkingSpot> _parkingSpots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Timer automatycznie odświeża dane co 10 sekund
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      _fetchAndUpdateData();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _fetchAndUpdateData();
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAndUpdateData() async {
    try {
      final data = await _fetchData();
      setState(() {
        _reservations = data['reservations'];
        _parkingSpots = data['parkingSpots'];
      });
    } catch (e) {
      debugPrint('Error fetching and updating data: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final secureStorage = GetIt.instance<SecureStorageService>();
    final token = await secureStorage.getToken();

    if (token == null) {
      throw Exception('No valid token found. Please log in.');
    }

    final parkingSpots = await ApiService.getParkingStatus();
    final reservations = await ApiService.fetchAllReservations();

    final activeReservations = reservations
        .where((r) => r.status.toLowerCase() != 'cancelled')
        .toList();

    debugPrint('Active Reservations: $activeReservations');
    debugPrint('Parking Spots: $parkingSpots');

    return {
      'parkingSpots': parkingSpots,
      'reservations': activeReservations,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: ParkingGrid(parkingSpots: _parkingSpots),
              ),
              Expanded(
                flex: 2,
                child: ReservationsSection(
                  reservations: _reservations,
                  forAll: true,
                  canCancelHere: false,
                  onReservationChanged: _fetchAndUpdateData, // Callback do odświeżania danych
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
