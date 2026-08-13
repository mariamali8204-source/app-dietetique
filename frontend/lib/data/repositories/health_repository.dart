import '../datasources/remote/health_remote_data_source.dart';

class HealthRepository {
  HealthRepository({required this.remoteDataSource});

  final HealthRemoteDataSource remoteDataSource;

  Future<HealthResult> checkHealth() {
    return remoteDataSource.checkHealth();
  }
}
