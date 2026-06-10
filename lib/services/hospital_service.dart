import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class HospitalService {
  static String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null) {
      throw Exception('API_BASE_URL not found in .env file');
    }
    return url;
  }

  static Future<List<dynamic>> getNearbyHospitals(String h3Index) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/hospitals/nearby?h3_index=$h3Index'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch nearby hospitals');
    }
  }

  static Future<List<dynamic>> searchHospitals(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/hospitals/search?q=$query'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search hospitals');
    }
  }
}
