import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_parking/models/parking_spot.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
  static final String _loginEndpoint = dotenv.env['LOGIN_ENDPOINT'] ?? '/login';
  static final String _reservationsEndpoint =
      dotenv.env['RESERVATIONS_ENDPOINT'] ?? '/reservations';
  static final String _parkingStatusEndpoint =
      dotenv.env['PARKING_STATUS_ENDPOINT'] ?? '/parking_status';
  static final String _reserveEndpoint =
      dotenv.env['RESERVE_ENDPOINT'] ?? '/reserve';

  static final Logger logger = Logger();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_loginEndpoint'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUserReservations(
      String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_reservationsEndpoint'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    logger.d('Fetching reservations with token: $token');
    logger.d('API Response Status: ${response.statusCode}');
    logger.d('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> reservations = json.decode(response.body);
      return reservations.map((r) => r as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch reservations: ${response.body}');
    }
  }

  static Future<List<ParkingSpot>> getParkingStatus(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_parkingStatusEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    logger.d('Fetching parking status with token: $token');
    logger.d('API Response Status: ${response.statusCode}');
    logger.d('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => ParkingSpot.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load parking status: ${response.body}');
    }
  }

  static Future<void> cancelReservation(String parkingSpotId, String date,
      String startTime, String endTime, String token) async {
    final formattedDate =
        DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(date));

    final requestBody = {
      'parking_spot_id': parkingSpotId,
      'action': 'cancel',
      'reservation_date': formattedDate,
      'reservation_start_time': startTime,
      'reservation_end_time': endTime,
    };

    logger.d(
        "Sending request to $_baseUrl$_reserveEndpoint with body: ${json.encode(requestBody)}");

    final response = await http.post(
      Uri.parse('$_baseUrl$_reserveEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(requestBody),
    );

    logger.d("Response status: ${response.statusCode}");
    logger.d("Response body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel reservation');
    }
  }

  static String formatTime(String time) {
    if (time.contains(':') && time.split(':').length == 2) {
      return '$time:00';
    }
    return time;
  }

  static Future<void> reserveParkingSpot({
    required String parkingSpotId,
    required String action,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String token,
  }) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final body = {
      'parking_spot_id': parkingSpotId,
      "action": action,
      'reservation_date': formattedDate,
      "reservation_start_time": formatTime(startTime),
      "reservation_end_time": formatTime(endTime),
    };

    logger.d('Body before sending: $body');
    logger.d('Sending Reservation with body: $body');

    final response = await http.post(
      Uri.parse('$_baseUrl$_reserveEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    logger.d('API Response Status: ${response.statusCode}');
    logger.d('API Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to reserve parking spot: ${response.body}');
    }
  }
}
