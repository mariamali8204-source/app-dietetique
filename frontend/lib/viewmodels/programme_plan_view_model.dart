import 'package:flutter/foundation.dart';

import '../core/errors/unauthorized_exception.dart';
import '../data/repositories/programme_plan_repository.dart';
import '../models/programme_plan.dart';

typedef ProgrammeUnauthorizedHandler = Future<void> Function();

class ProgrammePlanViewModel extends ChangeNotifier {
  ProgrammePlanViewModel({
    required this.repository,
    required this.onUnauthorized,
  });

  final ProgrammePlanRepository repository;
  final ProgrammeUnauthorizedHandler onUnauthorized;

  ProgrammePlan? _programme;

  bool _isLoading = false;
  bool _isSaving = false;

  String? _errorMessage;

  ProgrammePlan? get programme => _programme;

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  List<PlanJour> get semaine1 => _programme?.semaine1 ?? const [];

  List<PlanJour> get semaine2 => _programme?.semaine2 ?? const [];

  Future<bool> loadProgramme(int planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _programme = await repository.getProgramme(planId);

      return true;
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;

      await onUnauthorized();

      return false;
    } catch (_) {
      _errorMessage = 'Impossible de charger le programme nutritionnel.';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateJour({required int planId, required PlanJour jour}) async {
    final programmeActuel = _programme;

    if (programmeActuel == null) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final jourMisAJour = await repository.updateJour(
        planId: planId,
        jour: jour,
      );

      final jours = List<PlanJour>.from(programmeActuel.jours);

      final index = jours.indexWhere(
        (element) => element.id == jourMisAJour.id,
      );

      if (index == -1) {
        _errorMessage = 'Jour du programme introuvable.';
        return false;
      }

      jours[index] = jourMisAJour;

      _programme = ProgrammePlan(planId: programmeActuel.planId, jours: jours);

      return true;
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;

      await onUnauthorized();

      return false;
    } catch (_) {
      _errorMessage = 'Impossible de modifier les informations du jour.';

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateRepas({
    required int planId,
    required PlanRepas repas,
  }) async {
    final programmeActuel = _programme;

    if (programmeActuel == null) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final repasMisAJour = await repository.updateRepas(
        planId: planId,
        repas: repas,
      );

      final jours = List<PlanJour>.from(programmeActuel.jours);

      final jourIndex = jours.indexWhere(
        (jour) => jour.id == repasMisAJour.jourId,
      );

      if (jourIndex == -1) {
        _errorMessage = 'Jour associé au repas introuvable.';
        return false;
      }

      final jour = jours[jourIndex];

      final repasDuJour = List<PlanRepas>.from(jour.repas);

      final repasIndex = repasDuJour.indexWhere(
        (element) => element.id == repasMisAJour.id,
      );

      if (repasIndex == -1) {
        _errorMessage = 'Repas introuvable.';
        return false;
      }

      repasDuJour[repasIndex] = repasMisAJour;

      jours[jourIndex] = jour.copyWith(repas: repasDuJour);

      _programme = ProgrammePlan(planId: programmeActuel.planId, jours: jours);

      return true;
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;

      await onUnauthorized();

      return false;
    } catch (_) {
      _errorMessage = 'Impossible de modifier le repas.';

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  PlanJour? findJourById(int jourId) {
    final programmeActuel = _programme;

    if (programmeActuel == null) {
      return null;
    }

    for (final jour in programmeActuel.jours) {
      if (jour.id == jourId) {
        return jour;
      }
    }

    return null;
  }

  PlanRepas? findRepasById(int repasId) {
    final programmeActuel = _programme;

    if (programmeActuel == null) {
      return null;
    }

    for (final jour in programmeActuel.jours) {
      for (final repas in jour.repas) {
        if (repas.id == repasId) {
          return repas;
        }
      }
    }

    return null;
  }

  void clearProgramme() {
    _programme = null;
    _isLoading = false;
    _isSaving = false;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}
