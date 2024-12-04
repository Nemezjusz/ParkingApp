import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_parking/models/reservation.dart';
import 'package:smart_parking/widgets/dialogs/loading_dialog.dart';
import 'package:smart_parking/services/api_service.dart';

class ReservationItem extends StatelessWidget {
  final Reservation reservation;
  final bool canCancelHere;
  final VoidCallback onActionCompleted;

  const ReservationItem({
    Key? key,
    required this.reservation,
    required this.canCancelHere,
    required this.onActionCompleted,
  }) : super(key: key);

  Future<void> _cancelReservation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: Text(
          'Do you want to cancel the reservation for spot ${reservation.prettyId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      LoadingDialog.show(context);
      try {
        await ApiService.cancelReservation(
          reservation.parkingSpotId,
          reservation.reservationDate,
        );
        LoadingDialog.hide(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation canceled successfully.')),
        );
      } catch (e) {
        LoadingDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    onActionCompleted();
  }

  @override
  Widget build(BuildContext context) {
    if (reservation.status.toLowerCase() == 'cancelled') {
      return const SizedBox.shrink();
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(
      DateTime.parse(reservation.reservationDate),
    );

    IconData statusIcon;
    switch (reservation.status.toLowerCase()) {
      case 'reserved':
        statusIcon = Icons.access_time;
        break;
      case 'occupied':
        statusIcon = Icons.block;
        break;
      case 'confirmed':
        statusIcon = Icons.check_circle;
        break;
      default:
        statusIcon = Icons.check_circle_outline;
        break;
    }

    final primaryColor = Theme.of(context).primaryColor;
    return Card(
      color: primaryColor.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        leading: Icon(statusIcon, color: Colors.white, size: 30),
        title: Text(
          'Spot: ${reservation.prettyId}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: $formattedDate',
              style: GoogleFonts.poppins(
                color: Colors.white70,
              ),
            ),
            if (reservation.reservedBy != null)
              Text(
                'Reserved By: ${reservation.reservedBy?.replaceAll('BÅaÅ¼ej', 'Błażej').replaceAll('KwaÅny', 'Kwaśny').replaceAll('RosÃ³Å', 'Rosół')}',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        trailing: canCancelHere
            ? IconButton(
                icon: Icon(Icons.cancel, color: Colors.white70, size: 30),
                onPressed: () => _cancelReservation(context),
              )
            : null,
      ),
    );
  }
}

