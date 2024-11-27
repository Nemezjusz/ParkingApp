import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_parking/models/parking_spot.dart';
import 'package:smart_parking/models/reservation.dart';
import 'package:smart_parking/services/api_service.dart';
import 'package:smart_parking/services/local_notification_service.dart';

class ParkingStatusPollingService {
  final String token;
  final BuildContext context;
  Timer? _pollingTimer;
  List<ParkingSpot> _previousParkingState = [];
  List<Reservation> _previousUserReservations = [];

  ParkingStatusPollingService({required this.token, required this.context});

  Future<void> initialize() async {
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchAndCompareData();
    });
  }

  Future<void> _fetchAndCompareData() async {
    try {
      final newParkingState = await ApiService.getParkingStatus(token);
      final newUserReservations = await ApiService.fetchUserReservations(token);
      final allReservations = await ApiService.fetchAllReservations(token);

      for (var newSpot in newParkingState) {
        final oldSpot = _previousParkingState.firstWhere(
          (spot) => spot.id == newSpot.id,
          orElse: () => newSpot,
        );

        // Zmiana statusu z "free" na "reserved"
        if (oldSpot.status == "free" && newSpot.status == "reserved") {
          final reservation = allReservations.firstWhere(
            (r) => r.parkingSpotId == newSpot.id,
          );

          if (reservation != null &&
              reservation.reservedBy == ApiService.currentUserId) {
            LocalNotificationService().showCustomNotification(
              title: 'Spot Reserved',
              body: 'You have reserved parking spot ${newSpot.prettyId}.',
              payload: newSpot.id,
            );
          } else {
            LocalNotificationService().showCustomNotification(
              title: 'Spot Reserved by Someone Else',
              body: 'Spot ${newSpot.prettyId} is now reserved.',
              payload: newSpot.id,
            );
          }
        }

        // Zmiana statusu z "reserved" na "occupied"
        if (oldSpot.status == "reserved" && newSpot.status == "occupied") {
          final reservation = allReservations.firstWhere(
            (r) => r.parkingSpotId == newSpot.id,
          );

          if (reservation != null &&
              reservation.reservedBy == ApiService.currentUserId) {
            LocalNotificationService().showCustomNotification(
              title: 'Spot Occupied',
              body: 'Your reserved spot ${newSpot.prettyId} is now occupied.',
              payload: newSpot.id,
            );
          } else {
            LocalNotificationService().showCustomNotification(
              title: 'Spot Occupied',
              body: 'Spot ${newSpot.prettyId} is now occupied.',
              payload: newSpot.id,
            );
          }
        }

        // Zmiana statusu z "reserved" lub "occupied" na "free"
        if ((oldSpot.status == "reserved" || oldSpot.status == "occupied") &&
            newSpot.status == "free") {
          LocalNotificationService().showCustomNotification(
            title: 'Spot Now Free',
            body: 'Spot ${newSpot.prettyId} is now available.',
            payload: newSpot.id,
          );
        }
      }

      // Zaktualizuj poprzedni stan
      _previousParkingState = newParkingState;
      _previousUserReservations = newUserReservations;
    } catch (e) {
      debugPrint('Error fetching or comparing data: $e');
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
  }
}
