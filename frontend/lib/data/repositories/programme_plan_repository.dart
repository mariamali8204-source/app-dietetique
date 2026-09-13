import '../../models/programme_plan.dart';
import '../datasources/remote/programme_plan_remote_data_source.dart';

class ProgrammePlanRepository {
  ProgrammePlanRepository({required this.remoteDataSource});

  final ProgrammePlanRemoteDataSource remoteDataSource;

  Future<ProgrammePlan> getProgramme(int planId) {
    return remoteDataSource.getProgramme(planId);
  }

  Future<PlanJour> updateJour({required int planId, required PlanJour jour}) {
    return remoteDataSource.updateJour(planId: planId, jour: jour);
  }

  Future<PlanRepas> updateRepas({
    required int planId,
    required PlanRepas repas,
  }) {
    return remoteDataSource.updateRepas(planId: planId, repas: repas);
  }
}
