import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:smart_parking/widgets/dialogs/loading_dialog.dart';
import 'package:smart_parking/widgets/your_reservations_section.dart';
import 'package:smart_parking/widgets/reservation_form.dart';
import '../../blocs/reservation_form_bloc.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReservationFormBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: FormBlocListener<ReservationFormBloc, String, String>(
              onSubmitting: (context, state) => LoadingDialog.show(context),
              onSubmissionFailed: (context, state) => LoadingDialog.hide(context),
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.successResponse!)),
                );
                Navigator.pop(context);
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failureResponse!)),
                );
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      ReservationForm(),
                      YourReservationsSection(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
