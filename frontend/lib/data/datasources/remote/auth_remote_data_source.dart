import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../models/user.dart';

class AuthRemoteDataSource {
  Future<User> register({
    required String nom,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/register');

    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'nom': nom, 'email': email, 'password': password}),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 201) {
      throw Exception(
        _getErrorMessage(response, 'Erreur lors de la création du compte.'),
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return User.fromJson(data);
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'username': email, 'password': password},
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception(
        _getErrorMessage(response, 'E-mail ou mot de passe incorrect.'),
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final accessToken = data['access_token'];

    if (accessToken is! String || accessToken.isEmpty) {
      throw Exception('Token d’authentification invalide.');
    }

    return accessToken;
  }

  Future<User> getCurrentUser({required String token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/me');

    final response = await http
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception(
        _getErrorMessage(
          response,
          'Impossible de récupérer le profil utilisateur.',
        ),
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return User.fromJson(data);
  }

  String _getErrorMessage(http.Response response, String defaultMessage) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final detail = data['detail'];

      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
    } catch (_) {
      // Utiliser le message par défaut.
    }

    return defaultMessage;
  }
}
