import 'package:flutter/material.dart';
import 'package:smart_parking/constants/constants.dart';
import 'package:smart_parking/widgets/custom_title.dart';
import 'reservation_item.dart';

class YourReservationsSection extends StatelessWidget {
  const YourReservationsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTitle(icon: Icons.calendar_today, title: 'Your Parking Reservations'),
        
        ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: const [
            ReservationItem(
              spot: 'A1',
              status: 'Reserved',
              time: '10:00 - 12:00',
              color: parkingSpotReserved,
            ),
            ReservationItem(
              spot: 'B2',
              status: 'Occupied',
              time: '14:00 - 16:00',
              color: parkingSpotOccupied,
            ),
          ],
        ),
      ],
    );
  }
}
