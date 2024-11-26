import 'package:flutter/material.dart';
import 'package:smart_parking/services/api_service.dart';
import 'package:smart_parking/widgets/dialogs/loading_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:smart_parking/blocs/auth_state.dart';

class ReservationItem extends StatelessWidget {
  final String parkingSpotId;
  final String spot;
  final String status;
  final String date;
  final String startTime;
  final String endTime;
  final Color color;
  final VoidCallback onReservationCancelled;

  const ReservationItem({
    super.key,
    required this.parkingSpotId,
    required this.spot,
    required this.status,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.onReservationCancelled,
  });

  void _cancelReservation(BuildContext context, String parkingSpotId,
      String date, String startTime, String endTime, String spot) async {
    // Pokaż potwierdzenie
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: Text('Are you sure you want to cancel the reservation for spot $spot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Nie'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Tak'),
          ),
        ],
      ),
    );

    if (confirm != null && confirm) {
      LoadingDialog.show(context);
      try {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          await ApiService.cancelReservation(parkingSpotId, date, startTime, endTime, authState.token);
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
    switch (status.toLowerCase()) {
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
          'Miejsce: $spot',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Data: $date\nOkres rezerwacji: $startTime - $endTime\nStatus: $status',
          style: GoogleFonts.poppins(
            color: Colors.white70,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.white, size: 30),
          onPressed: () => _cancelReservation(context, parkingSpotId, date, startTime, endTime, spot),
        ),
      ),
    );
  }
}
