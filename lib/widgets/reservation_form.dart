import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:smart_parking/widgets/custom_title.dart';
import 'package:smart_parking/widgets/fields/input_widget.dart';
import 'package:smart_parking/widgets/primary_button.dart';
import 'package:smart_parking/constants/constants.dart';
import '../../blocs/reservation_form_bloc.dart';
import 'package:intl/intl.dart';

class ReservationForm extends StatelessWidget {
  final String? parkingSpotId; // Optional parking spot ID

  const ReservationForm({Key? key, this.parkingSpotId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reservationFormBloc = context.read<ReservationFormBloc>();

    // Automatically fill the parkingSpotId field if provided
    if (parkingSpotId != null) {
      reservationFormBloc.parkingSpotId.updateValue(parkingSpotId!);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTitle(icon: Icons.book_online, title: 'Reserve a Parking Slot'),

        // Parking Spot ID field with read-only setting based on parkingSpotId
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: InputWidget(
            hintText: "Parking Spot ID",
            prefixIcon: Icons.local_parking,
            fieldBloc: reservationFormBloc.parkingSpotId,
            autofillHints: const [AutofillHints.username],
            isReadOnly: parkingSpotId != null, // Make non-editable if parkingSpotId is set
          ),
        ),

        // Reservation Date Picker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: DateTimeFieldBlocBuilder(
            dateTimeFieldBloc: reservationFormBloc.reservationDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            format: DateFormat('yyyy-MM-dd'),
            decoration: InputDecoration(
              labelText: "Reservation Date",
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
            ),
            initialDate: DateTime.now(),
          ),
        ),
        const SizedBox(height: kDefaultPadding),

        // Reserve Slot button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: PrimaryButton(
            text: "Reserve Slot",
            press: () => reservationFormBloc.submit(),
          ),
        ),
        const SizedBox(height: kDefaultPadding * 2),
      ],
    );
  }
}
