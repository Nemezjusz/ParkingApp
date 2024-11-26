import 'dart:convert';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginFormBloc extends FormBloc<String, String> {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
  static final String _loginEndpoint = dotenv.env['LOGIN_ENDPOINT'] ?? '/login';

  final TextFieldBloc email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final TextFieldBloc password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      // FieldBlocValidators.passwordMin6Chars,  // Tymczasowo wyłączone bo hasło to 2137
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
      logger.i('--- Wysłanie żądania logowania do $_baseUrl$_loginEndpoint ---');
      final response = await http.post(
        Uri.parse('$_baseUrl$_loginEndpoint'),
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
