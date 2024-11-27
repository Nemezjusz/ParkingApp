import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:smart_parking/blocs/reservation_form_bloc.dart';
import 'package:smart_parking/widgets/dialogs/loading_dialog.dart';
import 'package:smart_parking/widgets/reservations_section.dart';
import 'package:smart_parking/widgets/reservation_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:smart_parking/blocs/auth_state.dart';
import 'package:smart_parking/services/api_service.dart';
import 'package:smart_parking/blocs/parking_spot_bloc.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  void refreshReservations() {
    setState(() {});
    context.read<ParkingSpotBloc>().add(FetchParkingSpots());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return Scaffold(
        body: Center(
          child: Text(
            'You need to be logged in to make a reservation',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      );
    }
    final String token = authState.token!;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ReservationFormBloc>(
          create: (context) => ReservationFormBloc(token: token),
        ),
        BlocProvider<ParkingSpotBloc>(
          create: (context) =>
              ParkingSpotBloc(token: token)..add(FetchParkingSpots()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Spot Reservation',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              centerTitle: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              elevation: 0,
            ),
            body: FormBlocListener<ReservationFormBloc, String, String>(
              onSubmitting: (context, state) => LoadingDialog.show(context),
              onSubmissionFailed: (context, state) =>
                  LoadingDialog.hide(context),
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successResponse!),
                    backgroundColor: Colors.green,
                  ),
                );
                refreshReservations();
                context.read<ParkingSpotBloc>().add(FetchParkingSpots());
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.failureResponse!),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const ReservationForm(),
                    const SizedBox(height: 20),
                    ReservationsSection(
                      fetchReservations: () =>
                          ApiService.fetchUserReservations(token),
                      title: 'Your Reservations',
                      icon: Icons.calendar_today,
                      onRefresh: refreshReservations,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
