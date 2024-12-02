import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/reservation_form_bloc.dart';
import 'package:smart_parking/models/reservation.dart';
import 'package:smart_parking/screens/views/universal/reservations_section.dart';
import 'package:smart_parking/widgets/reservation_form.dart';
import 'package:smart_parking/services/api_service.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  _ReservationViewState createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  late Future<List<Reservation>> _reservationsFuture;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchReservations();
    });
  }

  void _fetchReservations() {
    setState(() {
      _reservationsFuture = ApiService.fetchUserReservations();
    });
  }

  void _onReservationAdded() {
    _fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReservationFormBloc(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ReservationForm(onReservationAdded: _onReservationAdded),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Reservation>>(
                  future: _reservationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No reservations found.');
                    }
                    return ReservationsSection(
                      reservations: snapshot.data!,
                      forAll: false,
                      canCancelHere: true,
                      onReservationChanged: _fetchReservations,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
