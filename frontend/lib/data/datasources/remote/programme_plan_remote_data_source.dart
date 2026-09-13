import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/errors/unauthorized_exception.dart';
import '../../../models/programme_plan.dart';
import '../local/auth_local_data_source.dart';

class ProgrammePlanRemoteDataSource {
  ProgrammePlanRemoteDataSource({required this.authLocalDataSource});

  final AuthLocalDataSource authLocalDataSource;

  Future<ProgrammePlan> getProgramme(int planId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/plans/$planId/programme');

    final response = await http
        .get(uri, headers: await _authHeaders())
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response,
          fallback: 'Impossible de charger le programme nutritionnel.',
        ),
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return ProgrammePlan.fromJson(json);
  }

  Future<PlanJour> updateJour({
    required int planId,
    required PlanJour jour,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/plans/'
      '$planId/jours/${jour.id}',
    );

    final response = await http
        .patch(
          uri,
          headers: await _authHeaders(includeJsonContentType: true),
          body: jsonEncode(jour.toUpdateJson()),
        )
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response,
          fallback: 'Impossible de modifier les informations du jour.',
        ),
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return PlanJour.fromJson({
      ...json,
      'repas': jour.repas
          .map(
            (repas) => {
              'id': repas.id,
              'jourId': repas.jourId,
              'typeRepas': repas.typeRepas,
              'heure': repas.heure,
              'contenu': repas.contenu,
              'calories': repas.calories,
              'ordre': repas.ordre,
              'notes': repas.notes,
              'createdAt': repas.createdAt.toIso8601String(),
              'updatedAt': repas.updatedAt.toIso8601String(),
            },
          )
          .toList(),
    });
  }

  Future<PlanRepas> updateRepas({
    required int planId,
    required PlanRepas repas,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/plans/'
      '$planId/repas/${repas.id}',
    );

    final response = await http
        .patch(
          uri,
          headers: await _authHeaders(includeJsonContentType: true),
          body: jsonEncode(repas.toUpdateJson()),
        )
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response,
          fallback: 'Impossible de modifier le repas.',
        ),
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return PlanRepas.fromJson(json);
  }

  Future<Map<String, String>> _authHeaders({
    bool includeJsonContentType = false,
  }) async {
    final token = await authLocalDataSource.readToken();

    if (token == null || token.trim().isEmpty) {
      throw const UnauthorizedException(
        message: 'Utilisateur non authentifié.',
      );
    }

    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

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

  String _extractErrorMessage(
    http.Response response, {
    required String fallback,
  }) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];

        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
      }
    } catch (_) {
      // La réponse ne contient pas de JSON exploitable.
    }

    return fallback;
  }
}
