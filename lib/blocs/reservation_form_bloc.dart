import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:smart_parking/services/api_service.dart';
import 'package:logger/logger.dart';

class ReservationFormBloc extends FormBloc<String, String> {
  final String token;
  final Logger logger = Logger();

  // Fields
  final parkingSpotId = TextFieldBloc(); // Pole miejsca parkingowego
  final reservationDate = InputFieldBloc<DateTime, Object>(
    initialValue: DateTime.now(),
  );

  ReservationFormBloc({required this.token}) {
    addFieldBlocs(fieldBlocs: [parkingSpotId, reservationDate]);
  }

  @override
  Future<void> onSubmitting() async {
    logger.i('--- ReservationFormBloc: onSubmitting started ---');

    try {
      final parkingSpotIdValue = parkingSpotId.value;
      final dateValue = reservationDate.value;

      logger.i('Parking Spot ID: $parkingSpotIdValue');
      logger.i('Reservation Date: $dateValue');

      // Walidacja wartości ParkingSpotId
      if (parkingSpotIdValue.isEmpty) {
        logger.w('Parking spot ID is empty. Aborting submission.');
        emitFailure(failureResponse: "Parking spot ID is empty!");
        return;
      }

      // Sprawdź połączenie internetowe
      logger.i('Checking internet connection...');
      if (!await _hasInternetConnection()) {
        emitFailure(failureResponse: "No internet connection!");
        return;
      }

      // Wyślij rezerwację
      logger.i('Sending reservation to backend...');
      await ApiService.reserveParkingSpot(
        parkingSpotId: parkingSpotIdValue,
        action: 'reserve',
        date: dateValue,
        token: token,
      );
      logger.i('Reservation sent successfully.');

      emitSuccess(
          successResponse: "Reservation successful!");
    } catch (error) {
      logger.e('Error occurred during reservation: $error');
      emitFailure(failureResponse: "Error occurred during reservation!");
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
