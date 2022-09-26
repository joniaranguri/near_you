import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../Constants.dart';

class AdherencePrediction {
  static const String BASE_URL =
      "http://44.208.142.128:8501/v1/models/adherencia_model:predict";

  static Future<int> getPrediction(String? patientId) async {
    final uri = Uri.parse(BASE_URL);
    var requestBody = {};
    final response =
        await http.post(uri, headers: {}, body: jsonEncode(requestBody));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != HttpStatus.created) {
      return ADHERENCE_PREDICTION_ERROR;
    }
    int adherencePredictionRaw = decoded[PREDICTIONS_KEY][0][0];
    return adherencePredictionRaw.toInt() * 100;
  }
}
