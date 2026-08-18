import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  static const String _tokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  AuthLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
