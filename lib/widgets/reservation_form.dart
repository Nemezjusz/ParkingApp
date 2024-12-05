import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:smart_parking/blocs/reservation_form_bloc.dart';
import 'package:smart_parking/models/parking_spot.dart';
import 'package:smart_parking/screens/views/universal/section_header.dart';
import 'package:smart_parking/widgets/primary_button.dart';
import 'package:smart_parking/widgets/fields/input_widget.dart';

class ReservationForm extends StatelessWidget {
  final VoidCallback? onReservationAdded;

  const ReservationForm({super.key, this.onReservationAdded});

  @override
  Widget build(BuildContext context) {
    final reservationFormBloc = context.read<ReservationFormBloc>();

    return FormBlocListener<ReservationFormBloc, String, String>(
      onSubmitting: (context, state) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      onSuccess: (context, state) async {
        Navigator.of(context).pop(); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.successResponse!)),
        );

        // Odświeżanie miejsc parkingowych
        await reservationFormBloc.refreshAvailableSpots();

        // Wywołanie callbacku, jeśli istnieje
        if (onReservationAdded != null) {
          onReservationAdded!();
        }
      },
      onFailure: (context, state) {
        Navigator.of(context).pop(); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.failureResponse!)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
                icon: Icons.book_online, title: 'Reserve a Spot'),
            const SizedBox(height: 16),

            // Date Picker
            InputWidget<DateTime>(
              hintText: 'Reservation Date',
              prefixIcon: Icons.calendar_today,
              fieldBloc: reservationFormBloc.reservationDate,
              fieldType: FieldType.date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            ),
            const SizedBox(height: 16),

            // Parking Spot Selection
            InputWidget<ParkingSpot>(
              hintText: 'Select a Spot',
              prefixIcon: Icons.local_parking,
              fieldBloc: reservationFormBloc.parkingSpot,
              fieldType: FieldType.dropdown,
              items: reservationFormBloc.parkingSpot.state.items,
              itemBuilder: (context, spot) => Text(
                spot.prettyId ?? 'Unknown Spot',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            PrimaryButton(
              text: "Confirm",
              press: reservationFormBloc.submit,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}


