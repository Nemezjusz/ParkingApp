import 'package:flutter/material.dart';
import 'package:smart_parking/services/api_service.dart';
import 'package:smart_parking/widgets/dialogs/loading_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:smart_parking/blocs/auth_state.dart';
import 'package:smart_parking/models/reservation.dart';

class ReservationItem extends StatelessWidget {
  final Reservation reservation;
  final String date;
  final VoidCallback onReservationCancelled;

  const ReservationItem({
    Key? key,
    required this.reservation,
    required this.date,
    required this.onReservationCancelled,
  }) : super(key: key);

  void _cancelReservation(BuildContext context) async {
    // Dodaj logowanie daty przed wysłaniem do API
    print('Cancelling reservation with date: $date');

    // Pokaż potwierdzenie
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: Text(
            'Are you sure you want to cancel the reservation for spot ${reservation.prettyId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm != null && confirm) {
      LoadingDialog.show(context);
      try {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          await ApiService.cancelReservation(
              reservation.parkingSpotId, date, authState.token!);
          LoadingDialog.hide(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservation canceled successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          onReservationCancelled();
        } else {
          LoadingDialog.hide(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unauthorized. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        LoadingDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel reservation. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    Color color = _getColorByStatus(reservation.status);

    final authState = context.read<AuthBloc>().state;
    final currentUserEmail = (authState is Authenticated) ? authState.userEmail : null;

    // Determine if the reservation can be canceled: either reservedBy is null or matches currentUserEmail
    bool canCancel = (reservation.reservedBy == null) ||
        (currentUserEmail != null && reservation.reservedBy == currentUserEmail);

    return Card(
      color: color.withOpacity(0.9),
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
              'Date: $date',
              style: GoogleFonts.poppins(
                color: Colors.white70,
              ),
            ),
            if (reservation.reservedBy != null)
              Text(
                'Reserved By: ${reservation.reservedBy}',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),
            Text(
              'Status: ${reservation.status}',
              style: GoogleFonts.poppins(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        trailing: canCancel
            ? IconButton(
                icon: const Icon(Icons.cancel, color: Colors.white, size: 30),
                onPressed: () => _cancelReservation(context),
              )
            : null,
      ),
    );
  }

  Color _getColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'reserved':
        return Colors.yellow;
      case 'occupied':
        return Colors.red;
      case 'confirmed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
