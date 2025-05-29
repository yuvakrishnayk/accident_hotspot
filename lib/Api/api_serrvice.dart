import 'package:accident_hotspot/Models/model.dart';
import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'https://prediction-ml-model.onrender.com';
  final Dio dio = Dio();

  Future<Map<String, dynamic>> predictAccident(
      AccidentPrediction prediction) async {
    try {
      final response = await dio.post(
        '$baseUrl/predict',
        data: prediction.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to predict accident: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to predict accident: $e');
    }
  }
}
