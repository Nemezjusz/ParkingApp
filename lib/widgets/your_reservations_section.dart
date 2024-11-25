import 'package:flutter/material.dart';
import 'package:smart_parking/constants/constants.dart';
import 'package:smart_parking/widgets/custom_title.dart';
import 'reservation_item.dart';
import 'package:smart_parking/services/api_service.dart';
import 'package:smart_parking/models/reservation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:smart_parking/blocs/auth_state.dart';
import 'package:intl/intl.dart';

class YourReservationsSection extends StatefulWidget {
  const YourReservationsSection({super.key});

  @override
  _YourReservationsSectionState createState() =>
      _YourReservationsSectionState();
}

class _YourReservationsSectionState extends State<YourReservationsSection> {
  late Future<List<Reservation>> reservations;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      reservations = ApiService.fetchUserReservations(authState.token).then(
            (data) => data.map((json) => Reservation.fromJson(json)).toList(),
      );
    } else {
      reservations = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomTitle(
          icon: Icons.calendar_today,
          title: 'Twoje Rezerwacje',
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Reservation>>(
          future: reservations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Wystąpił błąd podczas ładowania rezerwacji.',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Brak zarejestrowanych rezerwacji.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final reservation = snapshot.data![index];
                  try {
                    final parsedDate = DateTime.parse(reservation.date);
                    final formattedDate =
                    DateFormat('dd-MM-yyyy').format(parsedDate);

                    return ReservationItem(
                      parkingSpotId: reservation.parkingSpotId,
                      spot: reservation.parkingPrettyId,
                      status: reservation.status,
                      date: formattedDate,
                      startTime: reservation.startTime,
                      endTime: reservation.endTime,
                      color: _getColorByStatus(reservation.status),
                    );
                  } catch (e) {
                    return ReservationItem(
                      parkingSpotId: reservation.parkingSpotId,
                      spot: reservation.parkingPrettyId,
                      status: reservation.status,
                      date: reservation.date,
                      startTime: reservation.startTime,
                      endTime: reservation.endTime,
                      color: _getColorByStatus(reservation.status),
                    );
                  }
                },
              );
            }
          },
        ),
      ],
    );
  }

  Color _getColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'reserved':
        return parkingSpotReserved;
      case 'occupied':
        return parkingSpotOccupied;
      case 'confirmed':
        return parkingSpotConfirmed;
      default:
        return parkingSpotFree;
    }
  }
}
