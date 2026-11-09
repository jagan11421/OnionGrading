
import 'dart:convert';
import 'package:http/http.dart' as http;

class MetricsService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> getMetrics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/model-metrics'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load model metrics');
  }
}
