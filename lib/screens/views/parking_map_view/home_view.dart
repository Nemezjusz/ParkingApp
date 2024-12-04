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
  List<Reservation> _allReservations = [];
  List<ParkingSpot> _oldParkingSpots = [];
  List<ParkingSpot> _currentParkingSpots = [];
  bool _isLoading = false;
  bool _isFetching = false;
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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
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
        _userReservations = data['userReservations'];
        _allReservations = data['allReservations'];
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
    if (_isFetching) return; // Zapobiegaj nakładaniu się zapytań
    _isFetching = true;

    try {
      final data = await _fetchData();
      final newParkingSpots = data['parkingSpots'];

      bool hasChanges = false;

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

        if (oldSpot.color != spot.color || oldSpot.status != spot.status) {
          hasChanges = true;
        }
      }

      if (hasChanges) {
        setState(() {
          _oldParkingSpots = newParkingSpots;
          _currentParkingSpots =
              newParkingSpots; // Aktualizacja danych przekazywanych do ParkingGrid
          _allReservations = data['allReservations'];
          _userReservations = data['userReservations'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching and comparing data: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final secureStorage = GetIt.instance<SecureStorageService>();
    final token = await secureStorage.getToken();

    if (token == null) {
      throw Exception('No valid token found. Please log in.');
    }

    final parkingSpots = await ApiService.getParkingStatus();
    final allReservations = await ApiService.fetchAllReservations();
    final userReservations = await ApiService.fetchUserReservations();

    return {
      'parkingSpots': parkingSpots,
      'allReservations': allReservations,
      'userReservations': userReservations,
    };
  }

  void _triggerNotificationAndDialog(ParkingSpot spot) async {
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
      '🚨 Parking Alert!',
      'Someone parked on your reserved spot: ${spot.prettyId} (Floor: ${spot.floor})!',
      notificationDetails,
    );

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final scaffoldBackgroundColor = theme.scaffoldBackgroundColor;

    final shouldConfirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            title: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.yellow,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Parking Spot Alert!',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Someone has parked on your reserved spot:',
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${spot.prettyId}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Floor: ${spot.floor}',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Do you want to confirm this parking?',
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldConfirm) {
      await _confirmParking(spot.id);

      // Wymuś odświeżenie widoku po zatwierdzeniu
      await _fetchAndCompareData();
      setState(() {});
    }
  }

  Future<void> _confirmParking(String parkingSpotId) async {
    try {
      await ApiService.confirmParkingSpot(parkingSpotId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking confirmed successfully!')),
      );
      await _fetchAndCompareData(); // Odśwież dane
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm parking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                    reservations: _allReservations,
                    forAll: true,
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
      ),
    );
  }
}
