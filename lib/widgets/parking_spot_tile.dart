import 'package:flutter/material.dart';
import 'package:smart_parking/widgets/reservation_form.dart';
import 'package:smart_parking/constants/constants.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../../blocs/reservation_form_bloc.dart';

class ParkingSpotTile extends StatelessWidget {
  final String id;
  final Color color;

  const ParkingSpotTile({required this.id, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (color == parkingSpotAvailable) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: sectionBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Reserve $id',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                      ),
                ),
                content: BlocProvider(
                  create: (context) => ReservationFormBloc(),
                  child: ReservationForm(parkingSpotId: id), // Przekazanie ID jako parametr
                ),
              );
            },
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            id,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
