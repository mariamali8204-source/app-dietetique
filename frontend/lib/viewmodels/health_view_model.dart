import 'package:flutter/foundation.dart';

import '../data/repositories/health_repository.dart';

class HealthViewModel extends ChangeNotifier {
  HealthViewModel({required this.repository});

  final HealthRepository repository;

  bool? _backendConnected;

  String _backendMessage = 'Vérification de la connexion...';

  bool _isChecking = false;

  bool? get backendConnected {
    return _backendConnected;
  }

  String get backendMessage {
    return _backendMessage;
  }

  bool get isChecking {
    return _isChecking;
  }

  Future<void> checkBackend() async {
    _isChecking = true;

    _backendConnected = null;

    _backendMessage = 'Vérification de la connexion...';

    notifyListeners();

    try {
      final result = await repository.checkHealth();

      _backendConnected = result.isConnected;

      _backendMessage = result.message;
    } catch (_) {
      _backendConnected = false;

      _backendMessage = 'Impossible de contacter FastAPI.';
    } finally {
      _isChecking = false;

      notifyListeners();
    }
  }
}
