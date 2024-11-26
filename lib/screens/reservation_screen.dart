import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:smart_parking/blocs/reservation_form_bloc.dart';
import 'package:smart_parking/widgets/dialogs/loading_dialog.dart';
import 'package:smart_parking/widgets/your_reservations_section.dart';
import 'package:smart_parking/widgets/reservation_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:smart_parking/blocs/auth_state.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final GlobalKey<YourReservationsSectionState> _reservationSectionKey =
      GlobalKey<YourReservationsSectionState>();

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return Scaffold(
        body: Center(
          child: Text('You need to be logged in to make a reservation'),
        ),
      );
    }
    final token = authState.token;

    return BlocProvider(
      create: (context) => ReservationFormBloc(token: token),
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
                // Odśwież rezerwacje
                _reservationSectionKey.currentState?.refreshReservations();
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
                    YourReservationsSection(key: _reservationSectionKey),
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
