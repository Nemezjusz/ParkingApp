import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:smart_parking/widgets/custom_title.dart';
import 'package:smart_parking/widgets/primary_button.dart';
import 'package:smart_parking/widgets/time_picker_field.dart';
import 'package:smart_parking/blocs/reservation_form_bloc.dart';
import 'package:smart_parking/blocs/parking_spot_bloc.dart';
import 'package:smart_parking/models/parking_spot.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ReservationForm extends StatelessWidget {
  const ReservationForm({super.key});

  @override
  Widget build(BuildContext context) {
    final reservationFormBloc = context.read<ReservationFormBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomTitle(
          icon: Icons.book_online,
          title: 'Reserve a Parking Spot',
        ),
        const SizedBox(height: 16),

        // Parking Spot Selection
        BlocBuilder<ParkingSpotBloc, ParkingSpotState>(
          builder: (context, state) {
            if (state is ParkingSpotLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ParkingSpotLoaded) {
              final freeSpots = state.parkingSpots
                  .where((spot) => spot.status == 'free')
                  .toList();
              if (freeSpots.isEmpty) {
                return const Text('No free parking spots available');
              }
              return DropdownSearch<ParkingSpot>(
                items: freeSpots,
                itemAsString: (ParkingSpot spot) =>
                    spot.prettyId, // Użyj prettyId
                onChanged: (ParkingSpot? selectedSpot) {
                  if (selectedSpot != null) {
                    reservationFormBloc.parkingSpotId
                        .updateValue(selectedSpot.id); // Użyj ID jako wartości
                  }
                },
                selectedItem: freeSpots.first,
                popupProps: PopupProps.menu(
                  constraints: const BoxConstraints(maxHeight: 300),
                  showSearchBox: true,
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Parking Spot",
                    prefixIcon: const Icon(Icons.local_parking),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            } else if (state is ParkingSpotError) {
              return Text('Error: ${state.message}');
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        const SizedBox(height: 16),

        // Date Picker
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate:
                  reservationFormBloc.reservationDate.value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (pickedDate != null) {
              reservationFormBloc.reservationDate.updateValue(pickedDate);
              // Wymuszenie odświeżenia widoku
              (context as Element).markNeedsBuild();
            }
          },
          child: BlocBuilder<ReservationFormBloc, FormBlocState>(
            builder: (context, state) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: "Date",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  reservationFormBloc.reservationDate.value != null
                      ? DateFormat('yyyy-MM-dd')
                          .format(reservationFormBloc.reservationDate.value!)
                      : 'Select Date',
                  style: TextStyle(
                    color: reservationFormBloc.reservationDate.value != null
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Time Pickers
        TimePickerFieldBlocBuilder(
          fieldBloc: reservationFormBloc.startTime,
          decoration: InputDecoration(
            labelText: "Start Time",
            prefixIcon: const Icon(Icons.access_time),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TimePickerFieldBlocBuilder(
          fieldBloc: reservationFormBloc.endTime,
          decoration: InputDecoration(
            labelText: "End Time",
            prefixIcon: const Icon(Icons.access_time),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: "Confirm",
            press: () => reservationFormBloc.submit(),
            color: Colors.blueAccent,
            textColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 5,
          ),
        ),
      ],
    );
  }
}
