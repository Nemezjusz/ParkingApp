import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:smart_parking/services/api_service.dart';
import 'package:logger/logger.dart';
import 'package:smart_parking/models/parking_spot.dart';

class ReservationFormBloc extends FormBloc<String, String> {
  final Logger logger = Logger();

  // Fields
  final parkingSpot = SelectFieldBloc<ParkingSpot, dynamic>();
  final reservationDate = InputFieldBloc<DateTime, dynamic>(
    initialValue: DateTime.now(),
  );

  ReservationFormBloc() {
    addFieldBlocs(fieldBlocs: [parkingSpot, reservationDate]);
    reservationDate.onValueChanges(onData: (previous, current) async* {
      await _filterParkingSpotsByDate(current.value);
    });
    _loadParkingSpots();
  }

  Future<void> _loadParkingSpots() async {
    emitLoading();
    try {
      final parkingSpots = await ApiService.getParkingStatus();
      final freeSpots = parkingSpots.where((spot) => spot.status == 'free').toList();
      parkingSpot.updateItems(freeSpots);
      emitLoaded();
    } catch (e) {
      logger.e('Error loading parking spots: $e');
      emitFailure(failureResponse: 'Failed to load parking spots.');
    }
  }

  Future<void> _filterParkingSpotsByDate(DateTime? date) async {
    if (date == null) return;

    emitLoading();
    try {
      final parkingSpots = await ApiService.getParkingStatus();
      final availableSpots = parkingSpots.where((spot) {
        final isSpotFree = spot.status == 'free' || _isSpotFreeOnDate(spot, date);
        return isSpotFree;
      }).toList();

      parkingSpot.updateItems(availableSpots);
      emitLoaded();
    } catch (e) {
      logger.e('Error filtering parking spots by date: $e');
      emitFailure(failureResponse: 'Failed to filter parking spots by date.');
    }
  }

  Future<void> refreshAvailableSpots() async {
    await _loadParkingSpots();
  }

  bool _isSpotFreeOnDate(ParkingSpot spot, DateTime date) {
    return true;
  }

  @override
  Future<void> onSubmitting() async {
    logger.i('--- ReservationFormBloc: onSubmitting started ---');
    try {
      final selectedSpot = parkingSpot.value;
      final date = reservationDate.value;

      if (selectedSpot == null) {
        emitFailure(failureResponse: "Please select a parking spot.");
        return;
      }

      if (date == null) {
        emitFailure(failureResponse: "Please select a reservation date.");
        return;
      }

      if (!await _hasInternetConnection()) {
        emitFailure(failureResponse: "No internet connection.");
        return;
      }

      await ApiService.reserveParkingSpot(
        parkingSpotId: selectedSpot.id,
        date: date,
      );
      await refreshAvailableSpots(); // Refresh spots after successful reservation
      emitSuccess(successResponse: "Reservation successful.");
    } catch (e) {
      logger.e('Error during reservation: $e');
      emitFailure(failureResponse: "An error occurred during reservation.");
    } finally {
      logger.i('--- ReservationFormBloc: onSubmitting ended ---');
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      return await InternetConnection().hasInternetAccess;
    } catch (e) {
      logger.e('Error checking internet connection: $e');
      return false;
    }
  }
}
