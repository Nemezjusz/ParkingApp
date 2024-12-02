import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/reservation_form_bloc.dart';
import 'package:smart_parking/models/reservation.dart';
import 'package:smart_parking/screens/views/universal/reservations_section.dart';
import 'package:smart_parking/widgets/reservation_form.dart';
import 'package:smart_parking/services/api_service.dart';

class ReservationView extends StatelessWidget {
  const ReservationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReservationFormBloc(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const ReservationForm(),
              const SizedBox(height: 20),
              // Sekcja rezerwacji użytkownika
              FutureBuilder<List<Reservation>>(
                future: ApiService.fetchUserReservations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No reservations found.');
                  }
                  return ReservationsSection(reservations: snapshot.data!, forAll: false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
