// api_service.dart
import 'dart:convert';
import 'package:accident_hotspot/Model/model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://jaga001.pythonanywhere.com';

  Future<Map<String, dynamic>> predictAccident(
      AccidentPrediction prediction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(prediction.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to predict accident: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to predict accident: $e');
    }
  }
}
