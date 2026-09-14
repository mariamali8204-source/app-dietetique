import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/errors/unauthorized_exception.dart';
import '../../../models/rendez_vous.dart';
import '../local/auth_local_data_source.dart';

class RendezVousConflictException implements Exception {
  const RendezVousConflictException({
    this.message = 'Ce créneau chevauche un autre rendez-vous.',
  });

  final String message;

  @override
  String toString() => message;
}

class RendezVousRemoteDataSource {
  RendezVousRemoteDataSource({required this.authLocalDataSource});

  final AuthLocalDataSource authLocalDataSource;

  Future<List<RendezVous>> getRendezVous({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final queryParameters = <String, String>{};

    if (dateDebut != null) {
      queryParameters['dateDebut'] = _formatDateApi(dateDebut);
    }

    if (dateFin != null) {
      queryParameters['dateFin'] = _formatDateApi(dateFin);
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/rendez-vous').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final response = await http
        .get(uri, headers: await _authHeaders())
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response,
          fallback: 'Impossible de charger les rendez-vous.',
        ),
      );
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;

    return decoded
        .map((item) => RendezVous.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<RendezVous>> getRendezVousDuJour(DateTime jour) async {
    final date = _formatDateApi(jour);

    final uri = Uri.parse('${ApiConfig.baseUrl}/rendez-vous/jour/$date');

    final response = await http
        .get(uri, headers: await _authHeaders())
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response,
          fallback: 'Impossible de charger les rendez-vous du jour.',
        ),
      );
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;

    return decoded
        .map((item) => RendezVous.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<RendezVous> getRendezVousById(int rendezVousId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/rendez-vous/$rendezVousId');

    final response = await http
        .get(uri, headers: await _authHeaders())
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response,
          fallback: 'Impossible de charger le rendez-vous.',
        ),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    return RendezVous.fromJson(decoded);
  }

  Future<RendezVous> createRendezVous(RendezVous rendezVous) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/rendez-vous');

    final response = await http
        .post(
          uri,
          headers: await _authHeaders(includeJsonContentType: true),
          body: jsonEncode(rendezVous.toCreateJson()),
        )
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);
    _checkConflict(response);

    if (response.statusCode != 201) {
      throw Exception(
        _extractErrorMessage(
          response,
          fallback: 'Impossible de créer le rendez-vous.',
        ),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    return RendezVous.fromJson(decoded);
  }

  Future<RendezVous> updateRendezVous(RendezVous rendezVous) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/rendez-vous/${rendezVous.id}');

    final response = await http
        .patch(
          uri,
          headers: await _authHeaders(includeJsonContentType: true),
          body: jsonEncode(rendezVous.toUpdateJson()),
        )
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);
    _checkConflict(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response,
          fallback: 'Impossible de modifier le rendez-vous.',
        ),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    return RendezVous.fromJson(decoded);
  }

  Future<void> deleteRendezVous(int rendezVousId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/rendez-vous/$rendezVousId');

    final response = await http
        .delete(uri, headers: await _authHeaders())
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response,
          fallback: 'Impossible de supprimer le rendez-vous.',
        ),
      );
    }
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

  void _checkConflict(http.Response response) {
    if (response.statusCode != 409) {
      return;
    }

    throw RendezVousConflictException(
      message: _extractErrorMessage(
        response,
        fallback: 'Ce créneau chevauche un autre rendez-vous.',
      ),
    );
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
      // La réponse ne contient pas
      // de JSON exploitable.
    }

    return fallback;
  }

  String _formatDateApi(DateTime date) {
    final mois = date.month.toString().padLeft(2, '0');

    final jour = date.day.toString().padLeft(2, '0');

    return '${date.year}-$mois-$jour';
  }
}
