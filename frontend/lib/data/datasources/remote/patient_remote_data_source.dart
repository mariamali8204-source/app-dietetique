import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/errors/unauthorized_exception.dart';
import '../../../models/patient.dart';
import '../local/auth_local_data_source.dart';

class PatientRemoteDataSource {
  final AuthLocalDataSource authLocalDataSource;

  PatientRemoteDataSource({required this.authLocalDataSource});

  Future<List<Patient>> getPatients() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/patients');

    final headers = await _getAuthHeaders();

    final response = await http
        .get(uri, headers: headers)
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

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

    final headers = await _getAuthHeaders(includeJsonContentType: true);

    final patientJson = Map<String, dynamic>.from(patient.toJson());

    patientJson.remove('id');
    patientJson.remove('userId');
    patientJson.remove('createdAt');
    patientJson.remove('updatedAt');

    final response = await http
        .post(uri, headers: headers, body: jsonEncode(patientJson))
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de l’ajout du patient.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return Patient.fromJson(data);
  }

  Future<Patient> updatePatient(Patient patient) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/patients/${patient.id}');

    final headers = await _getAuthHeaders(includeJsonContentType: true);

    final patientJson = Map<String, dynamic>.from(patient.toJson());

    patientJson.remove('id');
    patientJson.remove('userId');
    patientJson.remove('createdAt');
    patientJson.remove('updatedAt');

    final response = await http
        .put(uri, headers: headers, body: jsonEncode(patientJson))
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la modification du patient.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return Patient.fromJson(data);
  }

  Future<void> deletePatient(int patientId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/patients/$patientId');

    final headers = await _getAuthHeaders();

    final response = await http
        .delete(uri, headers: headers)
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression du patient.');
    }
  }

  Future<Map<String, String>> _getAuthHeaders({
    bool includeJsonContentType = false,
  }) async {
    final token = await authLocalDataSource.readToken();

    if (token == null || token.isEmpty) {
      throw const UnauthorizedException(
        message: 'Utilisateur non authentifié.',
      );
    }

    final headers = <String, String>{'Authorization': 'Bearer $token'};

    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }
  }
}
