import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_parking/services/service_locator.dart';

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
    ],
  );

  final Logger logger = Logger();
  final FlutterSecureStorage _storage = locator<FlutterSecureStorage>();

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

        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(
            key: 'auth_expiry',
            value: DateTime.now().add(Duration(days: 7)).toIso8601String());
        await _storage.write(key: 'user_email', value: email.value);

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
