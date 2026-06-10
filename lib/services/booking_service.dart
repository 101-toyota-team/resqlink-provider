import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/booking.dart';
import 'auth_service.dart';

class BookingService {
  static String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null) {
      throw Exception('API_BASE_URL not found in .env file');
    }
    return url;
  }

  static Future<List<Booking>> getProviderBookings(String providerId) async {
    final token = AuthService.accessToken;
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/providers/$providerId/bookings'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch bookings: ${response.statusCode}');
    }
  }

  static Future<void> assignAmbulance(String bookingId, String ambulanceId, {String? driverId}) async {
    final token = AuthService.accessToken;
    if (token == null) throw Exception('Not authenticated');

    final body = {
      'ambulance_id': ambulanceId,
    };
    if (driverId != null) {
      body['driver_id'] = driverId;
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/bookings/$bookingId/assign'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign ambulance: ${response.body}');
    }
  }

  static Future<void> updateBookingStatus(String bookingId, String status) async {
    final token = AuthService.accessToken;
    if (token == null) throw Exception('Not authenticated');

    final response = await http.put(
      Uri.parse('$_baseUrl/bookings/$bookingId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status: ${response.body}');
    }
  }
}
