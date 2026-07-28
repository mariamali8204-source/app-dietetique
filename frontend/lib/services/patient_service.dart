import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/patient.dart';

class PatientService {
  Future<List<Patient>> getPatients() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/patients');

      final response = await http.get(uri).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        return data
            .map((item) => Patient.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Erreur backend : ${response.statusCode}');
    } catch (_) {
      throw Exception('Impossible de charger les patients depuis le backend');
    }
  }
}