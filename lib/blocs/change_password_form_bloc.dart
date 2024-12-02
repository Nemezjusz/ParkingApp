import 'dart:convert';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_parking/services/service_locator.dart';

class ChangePasswordFormBloc extends FormBloc<String, String> {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
  static final String _changePasswordEndpoint =
      dotenv.env['CHANGE_PASSWORD_ENDPOINT'] ?? '/change-password';

  final TextFieldBloc currentPassword = TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );
  final TextFieldBloc newPassword = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars
    ],
  );

  final Logger logger = Logger();
  final FlutterSecureStorage _storage = locator<FlutterSecureStorage>();

  ChangePasswordFormBloc() {
    addFieldBlocs(fieldBlocs: [currentPassword, newPassword]);
  }

  @override
  Future<void> onSubmitting() async {
    logger.i('--- Rozpoczęcie procesu zmiany hasła ---');

    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      logger.i('--- Brak tokenu uwierzytelniającego ---');
      emitFailure(failureResponse: 'Nie jesteś zalogowany.');
      return;
    }

    try {
      logger.i('--- Wysłanie żądania zmiany hasła ---');
      final response = await http.post(
        Uri.parse('$_baseUrl$_changePasswordEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword.value,
          'new_password': newPassword.value,
        }),
      );

      if (response.statusCode == 200) {
        logger.i('--- Hasło zostało zmienione pomyślnie ---');
        emitSuccess();
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'Błąd serwera.';
        logger.i('--- Błąd serwera: $error ---');
        emitFailure(failureResponse: error);
      }
    } catch (e) {
      logger.i('--- Błąd podczas zmiany hasła: $e ---');
      emitFailure(failureResponse: 'Błąd podczas zmiany hasła.');
    }

    logger.i('--- Proces zmiany hasła zakończony ---');
  }
}
