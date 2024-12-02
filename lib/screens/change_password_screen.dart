import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:smart_parking/blocs/change_password_form_bloc.dart';
import 'package:smart_parking/widgets/dialogs/loading_dialog.dart';
import 'package:smart_parking/widgets/fields/input_widget.dart';
import 'package:smart_parking/widgets/primary_button.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = context.read<ChangePasswordFormBloc>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Change Password'),
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 2,
            ),
            body: FormBlocListener<ChangePasswordFormBloc, String, String>(
              onSubmitting: (context, state) => LoadingDialog.show(context),
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
                Navigator.pop(context);
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failureResponse ?? 'Error')),
                );
              },
              onLoading: (context, state) {
                LoadingDialog.show(context);
              },
              onSubmissionFailed: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Check your credentials and try again!"),
                  ),
                );
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          "Change Your Password",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      InputWidget(
                        hintText: "Current Password",
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        textInputType: TextInputType.visiblePassword,
                        autofillHints: const [AutofillHints.password],
                        fieldBloc: formBloc.currentPassword,
                      ),
                      const SizedBox(height: 16),
                      InputWidget(
                        hintText: "New Password",
                        prefixIcon: Icons.lock_reset,
                        obscureText: true,
                        textInputType: TextInputType.visiblePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        fieldBloc: formBloc.newPassword,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: "Change Password",
                        press: () => formBloc.submit(),
                      ),
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
