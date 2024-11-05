import 'dart:convert';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:http/http.dart' as http;

class LoginFormBloc extends FormBloc<String, String> {
  final TextFieldBloc email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final TextFieldBloc password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );

  LoginFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        email,
        password,
      ],
    );
  }

  @override
  Future<void> onSubmitting() async {
    try {
      final response = await http.post(
        Uri.parse('https://pilarz.dev/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'email': email.value,
          'password': password.value,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['access_token'];

        // Przekazujemy token przez emitSuccess
        emitSuccess(successResponse: token);
      } else {
        emitFailure(failureResponse: 'Niepoprawny email lub hasło.');
      }
    } catch (error) {
      emitFailure(failureResponse: 'Błąd podczas logowania.');
    }
  }
}
