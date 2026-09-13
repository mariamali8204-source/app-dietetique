import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/errors/unauthorized_exception.dart';
import '../../../models/plan_nutritionnel.dart';
import '../local/auth_local_data_source.dart';

class PlanNutritionnelRemoteDataSource {
  final AuthLocalDataSource authLocalDataSource;

  PlanNutritionnelRemoteDataSource({required this.authLocalDataSource});

  Future<List<PlanNutritionnel>> getPlans() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/plans');

    final headers = await _getAuthHeaders();

    final response = await http
        .get(uri, headers: headers)
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Impossible de charger les plans nutritionnels.');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data.map((item) {
      return PlanNutritionnel.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<PlanNutritionnel> addPlan(PlanNutritionnel plan) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/plans');

    final headers = await _getAuthHeaders(includeJsonContentType: true);

    final planJson = Map<String, dynamic>.from(plan.toJson());

    planJson.remove('id');
    planJson.remove('userId');
    planJson.remove('createdAt');
    planJson.remove('updatedAt');

    final response = await http
        .post(uri, headers: headers, body: jsonEncode(planJson))
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 201) {
      throw Exception('Impossible d’ajouter le plan nutritionnel.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return PlanNutritionnel.fromJson(data);
  }

  Future<PlanNutritionnel> updatePlan(PlanNutritionnel plan) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/plans/${plan.id}');

    final headers = await _getAuthHeaders(includeJsonContentType: true);

    final planJson = Map<String, dynamic>.from(plan.toJson());

    planJson.remove('id');
    planJson.remove('userId');
    planJson.remove('createdAt');
    planJson.remove('updatedAt');

    final response = await http
        .put(uri, headers: headers, body: jsonEncode(planJson))
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Impossible de modifier le plan nutritionnel.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return PlanNutritionnel.fromJson(data);
  }

  Future<void> deletePlan(int planId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/plans/$planId');

    final headers = await _getAuthHeaders();

    final response = await http
        .delete(uri, headers: headers)
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Impossible de supprimer le plan nutritionnel.');
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
