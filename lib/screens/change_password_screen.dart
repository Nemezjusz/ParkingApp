import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:smart_parking/blocs/change_password_form_bloc.dart';
import 'package:smart_parking/widgets/dialogs/loading_dialog.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return BlocProvider(
      create: (context) => ChangePasswordFormBloc(authBloc: authBloc),
      child: Builder(
        builder: (context) {
          final formBloc = context.read<ChangePasswordFormBloc>();

          return Scaffold(
            appBar: AppBar(
              title: Text('Change Password'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: FormBlocListener<ChangePasswordFormBloc, String, String>(
              onSubmitting: (context, state) => LoadingDialog.show(context),
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password changed successfully')),
                );
                Navigator.pop(context);
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failureResponse!)),
                );
              },
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  TextFieldBlocBuilder(
                    textFieldBloc: formBloc.currentPassword,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  TextFieldBlocBuilder(
                    textFieldBloc: formBloc.newPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock_open),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: formBloc.submit,
                    child: Text('Change Password'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
