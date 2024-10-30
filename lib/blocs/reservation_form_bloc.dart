import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ReservationFormBloc extends FormBloc<String, String> {
  // Pole dla ID miejsca parkingowego
  final parkingSpotId = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  // Pole wyboru daty rezerwacji
  final reservationDate = InputFieldBloc<DateTime, Object>(
    validators: [
      FieldBlocValidators.required,
    ], initialValue: DateTime.now(),
  );

  ReservationFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        parkingSpotId,
        reservationDate,
      ],
    );
  }

  @override
  Future<void> onSubmitting() async {
    try {
      // Sprawdzamy połączenie z internetem
      final bool isConnected = await InternetConnection().hasInternetAccess;
      if (!isConnected) {
        emitFailure(failureResponse: "No internet connection!");
        return;
      }

      // Logika zapisu rezerwacji
      // Zapisz dane rezerwacji w bazie danych lub backendzie
      // Dla uproszczenia, zakładamy, że proces zakończył się sukcesem

      emitSuccess(successResponse: "Parking slot reserved successfully!");
    } catch (error) {
      emitFailure(failureResponse: "An unknown error occurred.");
    }
  }
}
