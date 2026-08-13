import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

class HealthResult {
  const HealthResult({required this.isConnected, required this.message});

  final bool isConnected;
  final String message;
}

class HealthRemoteDataSource {
  Future<HealthResult> checkHealth() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/health');

    try {
      final response = await http.get(uri).timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        return const HealthResult(
          isConnected: false,
          message: 'Backend non accessible',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return HealthResult(
        isConnected: true,
        message: data['message']?.toString() ?? 'Backend FastAPI connecté',
      );
    } catch (_) {
      return const HealthResult(
        isConnected: false,
        message: 'Backend non accessible',
      );
    }
  }
}
