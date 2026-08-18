import '../../models/user.dart';
import '../datasources/local/auth_local_data_source.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<User> register({
    required String nom,
    required String email,
    required String password,
  }) {
    return remoteDataSource.register(
      nom: nom,
      email: email,
      password: password,
    );
  }

  Future<User> login({required String email, required String password}) async {
    final token = await remoteDataSource.login(
      email: email,
      password: password,
    );

    await localDataSource.saveToken(token);

    try {
      return await remoteDataSource.getCurrentUser(token: token);
    } catch (error) {
      await localDataSource.deleteToken();
      rethrow;
    }
  }

  Future<User?> restoreSession() async {
    final token = await localDataSource.readToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await remoteDataSource.getCurrentUser(token: token);
    } catch (_) {
      await localDataSource.deleteToken();
      return null;
    }
  }

  Future<String?> getToken() {
    return localDataSource.readToken();
  }

  Future<void> logout() {
    return localDataSource.deleteToken();
  }
}
