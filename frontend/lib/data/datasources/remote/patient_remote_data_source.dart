import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../models/patient.dart';

class PatientRemoteDataSource {
  Future<List<Patient>> getPatients() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/patients');

    final response = await http.get(uri).timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement des patients.');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data.map((item) {
      return Patient.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<Patient> addPatient(Patient patient) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/patients');

    final patientJson = Map<String, dynamic>.from(patient.toJson());

    patientJson.remove('id');
    patientJson.remove('createdAt');
    patientJson.remove('updatedAt');

    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(patientJson),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de l’ajout du patient.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return Patient.fromJson(data);
  }

  Future<Patient> updatePatient(Patient patient) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/patients/${patient.id}');

    final patientJson = Map<String, dynamic>.from(patient.toJson());

    patientJson.remove('id');
    patientJson.remove('createdAt');
    patientJson.remove('updatedAt');

    final response = await http
        .put(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(patientJson),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la modification du patient.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return Patient.fromJson(data);
  }

  Future<void> deletePatient(int patientId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/patients/$patientId');

    final response = await http.delete(uri).timeout(ApiConfig.timeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression du patient.');
    }
  }
}
