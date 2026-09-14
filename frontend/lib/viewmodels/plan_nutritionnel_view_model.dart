import 'package:flutter/foundation.dart';

import '../core/errors/unauthorized_exception.dart';
import '../data/repositories/plan_nutritionnel_repository.dart';
import '../models/plan_nutritionnel.dart';

typedef PlanUnauthorizedHandler = Future<void> Function();

class PlanNutritionnelViewModel extends ChangeNotifier {
  PlanNutritionnelViewModel({
    required this.repository,
    required this.onUnauthorized,
  });

  final PlanNutritionnelRepository repository;
  final PlanUnauthorizedHandler onUnauthorized;

  final List<PlanNutritionnel> _plans = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<PlanNutritionnel> get plans {
    return List.unmodifiable(_plans);
  }

  bool get isLoading => _isLoading;

  bool get isSubmitting => _isSubmitting;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  Future<void> loadPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final plansDepuisApi = await repository.getPlans();

      _plans
        ..clear()
        ..addAll(plansDepuisApi);
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;
      await onUnauthorized();
    } catch (_) {
      _errorMessage = 'Impossible de charger les plans nutritionnels.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPlan(PlanNutritionnel plan) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final planCree = await repository.addPlan(plan);

      _plans.insert(0, planCree);

      return true;
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;
      await onUnauthorized();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible d’ajouter le plan nutritionnel.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updatePlan(PlanNutritionnel plan) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final planMisAJour = await repository.updatePlan(plan);

      final index = _plans.indexWhere((planExistant) {
        return planExistant.id == planMisAJour.id;
      });

      if (index == -1) {
        _errorMessage = 'Le plan modifié est introuvable.';
        return false;
      }

      _plans[index] = planMisAJour;

      return true;
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;
      await onUnauthorized();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible de modifier le plan nutritionnel.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deletePlan(int planId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deletePlan(planId);

      _plans.removeWhere((plan) => plan.id == planId);

      return true;
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;
      await onUnauthorized();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible de supprimer le plan nutritionnel.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  PlanNutritionnel? findPlanById(int planId) {
    for (final plan in _plans) {
      if (plan.id == planId) {
        return plan;
      }
    }

    return null;
  }

  List<PlanNutritionnel> plansForPatient(int patientId) {
    return _plans.where((plan) => plan.patientId == patientId).toList();
  }

  void clearPlans() {
    _plans.clear();
    _isLoading = false;
    _isSubmitting = false;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
