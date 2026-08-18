import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';
import '../models/user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository repository;

  AuthViewModel({required this.repository});

  User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUser = await repository.login(
        email: email.trim(),
        password: password,
      );

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = _cleanErrorMessage(error);
      _currentUser = null;

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String nom,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.register(
        nom: nom.trim(),
        email: email.trim(),
        password: password,
      );

      _currentUser = await repository.login(
        email: email.trim(),
        password: password,
      );

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = _cleanErrorMessage(error);
      _currentUser = null;

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> restoreSession() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUser = await repository.restoreSession();
    } catch (error) {
      _currentUser = null;
      _errorMessage = _cleanErrorMessage(error);
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.logout();
    } catch (error) {
      _errorMessage = _cleanErrorMessage(error);
    } finally {
      _currentUser = null;
      _setLoading(false);
    }
  }

  Future<void> handleUnauthorized() async {
    try {
      await repository.logout();
    } catch (_) {
      // La session locale sera tout de même
      // considérée comme terminée.
    }

    _currentUser = null;

    _errorMessage = 'Session expirée. Veuillez vous reconnecter.';

    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}
