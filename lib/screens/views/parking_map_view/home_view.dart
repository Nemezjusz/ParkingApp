import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  List<Reservation> _userReservations = [];
  List<ParkingSpot> _oldParkingSpots = [];
  List<ParkingSpot> _currentParkingSpots = [];
  bool _isLoading = false;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadInitialData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeNotifications() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _notificationsPlugin.initialize(initializationSettings);
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _fetchAndCompareData();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _fetchData();
      setState(() {
        _userReservations = data['reservations'];
        _currentParkingSpots = data['parkingSpots'];
        _oldParkingSpots = List.from(_currentParkingSpots);
      });
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAndCompareData() async {
    try {
      final data = await _fetchData();
      final newParkingSpots = data['parkingSpots'];

      for (final spot in newParkingSpots) {
        final oldSpot = _oldParkingSpots.firstWhere(
          (old) => old.id == spot.id,
          orElse: () => ParkingSpot(
            id: '',
            prettyId: '',
            status: '',
            color: '',
            floor: 0,
            spotNumber: 0,
            waitingConfirmation: false,
          ),
        );

        if (oldSpot.color.toLowerCase() != 'blue' &&
            spot.color.toLowerCase() == 'blue' &&
            _userReservations.any((res) => res.parkingSpotId == spot.id)) {
          _triggerNotificationAndDialog(spot);
        }
      }

      setState(() {
        _oldParkingSpots = newParkingSpots;
      });
    } catch (e) {
      debugPrint('Error fetching and comparing data: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final secureStorage = GetIt.instance<SecureStorageService>();
    final token = await secureStorage.getToken();

    if (token == null) {
      throw Exception('No valid token found. Please log in.');
    }

    final parkingSpots = await ApiService.getParkingStatus();
    final reservations = await ApiService.fetchUserReservations();

    return {
      'parkingSpots': parkingSpots,
      'reservations': reservations,
    };
  }

  void _triggerNotificationAndDialog(ParkingSpot spot) async {
    // Show local notification
    const androidDetails = AndroidNotificationDetails(
      'parking_channel_id',
      'Parking Notifications',
      importance: Importance.high,
      priority: Priority.high,
      channelDescription: 'Notifications related to parking',
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Parking Alert',
      'Someone parked on your reserved spot: ${spot.prettyId}',
      notificationDetails,
    );

    // Show dialog
    final shouldConfirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Parking'),
            content: Text(
                'Someone has parked on your reserved spot (${spot.prettyId}). Do you want to confirm this parking?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldConfirm) {
      await _confirmParking(spot.id);
    }
  }

  Future<void> _confirmParking(String parkingSpotId) async {
    try {
      await ApiService.confirmParkingSpot(parkingSpotId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking confirmed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm parking: $e')),
      );
    }
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
                child: ParkingGrid(parkingSpots: _currentParkingSpots),
              ),
              Expanded(
                flex: 2,
                child: ReservationsSection(
                  reservations: _userReservations,
                  forAll: false,
                  canCancelHere: false,
                  onReservationChanged: _fetchAndCompareData,
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
