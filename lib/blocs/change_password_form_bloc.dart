import 'dart:convert';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:smart_parking/blocs/auth_state.dart';

class ChangePasswordFormBloc extends FormBloc<String, String> {
  final TextFieldBloc currentPassword = TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );
  final TextFieldBloc newPassword = TextFieldBloc(
    validators: [FieldBlocValidators.required, FieldBlocValidators.passwordMin6Chars],
  );

  final AuthBloc authBloc;

  ChangePasswordFormBloc({required this.authBloc}) {
    addFieldBlocs(fieldBlocs: [currentPassword, newPassword]);
  }

  @override
  void onSubmitting() async {
    final authState = authBloc.state;

    if (!authState.isAuthenticated || authState.token == null) {
      emitFailure(failureResponse: 'Nie jesteś zalogowany.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://pilarz.dev/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authState.token}',
        },
        body: jsonEncode({
          'current_password': currentPassword.value,
          'new_password': newPassword.value,
        }),
      );

      if (response.statusCode == 200) {
        emitSuccess();
      } else {
        final error = jsonDecode(response.body)['detail'];
        emitFailure(failureResponse: error);
      }
    } catch (e) {
      emitFailure(failureResponse: 'Błąd podczas zmiany hasła.');
    }
  }
}
