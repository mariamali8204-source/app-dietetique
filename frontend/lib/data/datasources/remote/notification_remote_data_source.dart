import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../models/app_notification.dart';
import '../local/auth_local_data_source.dart';

class NotificationUnauthorizedException implements Exception {
  const NotificationUnauthorizedException();
}

class NotificationRemoteDataSource {
  NotificationRemoteDataSource({required this.authLocalDataSource});

  final AuthLocalDataSource authLocalDataSource;

  Future<List<AppNotification>> getNotifications() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/notifications'),
          headers: await _headers(),
        )
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Impossible de charger les notifications.');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<int> getNombreNonLues() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/notifications/non-lues/count'),
          headers: await _headers(),
        )
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Impossible de charger le nombre de notifications.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return data['count'] as int;
  }

  Future<AppNotification> marquerCommeLue(int notificationId) async {
    final response = await http
        .patch(
          Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/lue'),
          headers: await _headers(),
        )
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Impossible de marquer la notification comme lue.');
    }

    return AppNotification.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> marquerToutesCommeLues() async {
    final response = await http
        .patch(
          Uri.parse('${ApiConfig.baseUrl}/notifications/tout-lire'),
          headers: await _headers(),
        )
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Impossible de marquer les notifications comme lues.');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId'),
          headers: await _headers(),
        )
        .timeout(ApiConfig.timeout);

    _checkUnauthorized(response);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Impossible de supprimer la notification.');
    }
  }

  Future<Map<String, String>> _headers() async {
    final token = await authLocalDataSource.readToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      throw const NotificationUnauthorizedException();
    }
  }
}
