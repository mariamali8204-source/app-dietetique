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

  Future<Patient> addPatient(Patient patient) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/patients');

      final body = {
        'userId': patient.userId,
        'nom': patient.nom,
        'email': patient.email,
        'pays': patient.pays,
        'indicatif': patient.indicatif,
        'telephone': patient.telephone,
        'objectifNutritionnel': patient.objectifNutritionnel,
        'statut': patient.statut,
        'notificationsAutorisees': patient.notificationsAutorisees,
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        return Patient.fromJson(data);
      }

      throw Exception('Erreur backend : ${response.statusCode}');
    } catch (_) {
      throw Exception('Impossible d’ajouter le patient dans le backend');
    }
  }

  Future<Patient> updatePatient(Patient patient) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/patients/${patient.id}');

      final body = {
        'userId': patient.userId,
        'nom': patient.nom,
        'email': patient.email,
        'pays': patient.pays,
        'indicatif': patient.indicatif,
        'telephone': patient.telephone,
        'objectifNutritionnel': patient.objectifNutritionnel,
        'statut': patient.statut,
        'notificationsAutorisees': patient.notificationsAutorisees,
      };

      final response = await http
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        return Patient.fromJson(data);
      }

      throw Exception('Erreur backend : ${response.statusCode}');
    } catch (_) {
      throw Exception('Impossible de modifier le patient dans le backend');
    }
  }

  Future<void> deletePatient(int patientId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/patients/$patientId');

      final response = await http.delete(uri).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return;
      }

      throw Exception('Erreur backend : ${response.statusCode}');
    } catch (_) {
      throw Exception('Impossible de supprimer le patient dans le backend');
    }
  }
}