import 'dart:convert';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

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

  final Logger logger = Logger();

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
    logger.i('--- Rozpoczęcie procesu logowania ---');

    try {
      logger.i('--- Wysłanie żądania logowania ---');
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/login'),
        // Uri.parse('https://pilarz.dev/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'email': email.value,
          'password': password.value,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['access_token'];

        logger.i('--- Logowanie zakończone sukcesem ---');
        emitSuccess(successResponse: token);
      } else {
        logger.i('--- Niepoprawny email lub hasło ---');
        emitFailure(failureResponse: 'Niepoprawny email lub hasło.');
      }
    } catch (error) {
      logger.i('--- Błąd podczas logowania: $error ---');
      emitFailure(failureResponse: 'Błąd podczas logowania.');
    }

    logger.i('--- Proces logowania zakończony ---');
  }
}
