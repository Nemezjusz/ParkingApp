import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:smart_parking/services/api_service.dart';
import 'package:logger/logger.dart';

class ReservationFormBloc extends FormBloc<String, String> {
  final String token;
  final Logger logger = Logger();

  // Fields
  final parkingSpotId =
      TextFieldBloc(validators: [FieldBlocValidators.required]);
  final reservationDate = InputFieldBloc<DateTime, Object>(
    validators: [FieldBlocValidators.required],
    initialValue: DateTime.now(),
  );
  final startTime = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final endTime = TextFieldBloc(validators: [FieldBlocValidators.required]);

  ReservationFormBloc({required this.token}) {
    addFieldBlocs(
        fieldBlocs: [parkingSpotId, reservationDate, startTime, endTime]);
  }

  @override
  Future<void> onSubmitting() async {
    logger.i('--- ReservationFormBloc: onSubmitting started ---');

    try {
      // Extract and validate field values
      final parkingSpotIdValue = parkingSpotId.value;
      final dateValue = reservationDate.value;
      final startTimeValue = startTime.value;
      final endTimeValue = endTime.value;

      logger.i('Parking Spot ID: $parkingSpotIdValue');
      logger.i('Reservation Date: $dateValue');
      logger.i('Start Time: $startTimeValue');
      logger.i('End Time: $endTimeValue');

      if (!_isTimeValid(startTimeValue, endTimeValue)) {
        emitFailure(
            failureResponse:
                "Godzina zakończenia musi być późniejsza niż godzina rozpoczęcia.");
        return;
      }

      // Check internet connection
      logger.i('Checking internet connection...');
      if (!await _hasInternetConnection()) {
        emitFailure(failureResponse: "Brak połączenia z internetem!");
        return;
      }

      // Send reservation
      logger.i('Sending reservation to backend...');
      await ApiService.reserveParkingSpot(
        parkingSpotId: parkingSpotIdValue,
        action: 'reserve',
        date: dateValue,
        startTime: startTimeValue,
        endTime: endTimeValue,
        token: token,
      );
      logger.i('Reservation sent successfully.');

      emitSuccess(
          successResponse: "Miejsce parkingowe zarezerwowane pomyślnie!");
    } catch (error) {
      logger.e('Error occurred during reservation: $error');
      emitFailure(failureResponse: "Wystąpił błąd: $error");
    } finally {
      logger.i('--- ReservationFormBloc: onSubmitting ended ---');
    }
  }

  // Validate start and end times
  bool _isTimeValid(String startTime, String endTime) {
    try {
      final startParts = startTime.split(':').map(int.parse).toList();
      final endParts = endTime.split(':').map(int.parse).toList();

      final startMinutes = startParts[0] * 60 + startParts[1];
      final endMinutes = endParts[0] * 60 + endParts[1];

      logger.d('Start Minutes: $startMinutes, End Minutes: $endMinutes');
      return endMinutes > startMinutes;
    } catch (e) {
      logger.w('Invalid time format: $e');
      return false;
    }
  }

  // Check for internet connection
  Future<bool> _hasInternetConnection() async {
    try {
      return await InternetConnection().hasInternetAccess;
    } catch (e) {
      logger.e('Error checking internet connection: $e');
      return false;
    }
  }
}
