import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';

class HealthResult {
  final bool isConnected;
  final String message;
  final int? statusCode;

  const HealthResult({
    required this.isConnected,
    required this.message,
    this.statusCode,
  });
}

class HealthService {
  Future<HealthResult> checkHealth() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/health');

      final response = await http.get(uri).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'ok') {
          return HealthResult(
            isConnected: true,
            message: 'Backend FastAPI connecté',
            statusCode: response.statusCode,
          );
        }

        return HealthResult(
          isConnected: false,
          message: 'Réponse inattendue du backend',
          statusCode: response.statusCode,
        );
      }

      return HealthResult(
        isConnected: false,
        message: 'Erreur backend : ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } catch (_) {
      return const HealthResult(
        isConnected: false,
        message: 'Backend non accessible',
      );
    }
  }
}