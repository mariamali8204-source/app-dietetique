import '../../models/plan_nutritionnel.dart';
import '../datasources/remote/plan_nutritionnel_remote_data_source.dart';

class PlanNutritionnelRepository {
  final PlanNutritionnelRemoteDataSource remoteDataSource;

  PlanNutritionnelRepository({required this.remoteDataSource});

  Future<List<PlanNutritionnel>> getPlans() {
    return remoteDataSource.getPlans();
  }

  Future<PlanNutritionnel> addPlan(PlanNutritionnel plan) {
    return remoteDataSource.addPlan(plan);
  }

  Future<PlanNutritionnel> updatePlan(PlanNutritionnel plan) {
    return remoteDataSource.updatePlan(plan);
  }

  Future<void> deletePlan(int planId) {
    return remoteDataSource.deletePlan(planId);
  }
}
