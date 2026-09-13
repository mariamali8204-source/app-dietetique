import 'package:flutter/foundation.dart';

import '../core/errors/unauthorized_exception.dart';
import '../data/datasources/remote/rendez_vous_remote_data_source.dart';
import '../data/repositories/rendez_vous_repository.dart';
import '../models/rendez_vous.dart';

typedef RendezVousUnauthorizedHandler = Future<void> Function();

class RendezVousViewModel extends ChangeNotifier {
  RendezVousViewModel({required this.repository, required this.onUnauthorized});

  final RendezVousRepository repository;
  final RendezVousUnauthorizedHandler onUnauthorized;

  final List<RendezVous> _rendezVous = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<RendezVous> get rendezVous {
    return List.unmodifiable(_rendezVous);
  }

  bool get isLoading => _isLoading;

  bool get isSubmitting => _isSubmitting;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  List<RendezVous> rendezVousDuJour(DateTime date) {
    final result = _rendezVous.where((rendezVous) {
      return _memeJour(rendezVous.dateRendezVous, date);
    }).toList();

    result.sort((a, b) => a.dateHeureDebut.compareTo(b.dateHeureDebut));

    return result;
  }

  List<RendezVous> get rendezVousAvenir {
    final maintenant = DateTime.now();

    final result = _rendezVous.where((rendezVous) {
      return !rendezVous.estAnnule &&
          !rendezVous.estTermine &&
          rendezVous.dateHeureFin.isAfter(maintenant);
    }).toList();

    result.sort((a, b) => a.dateHeureDebut.compareTo(b.dateHeureDebut));

    return result;
  }

  RendezVous? findRendezVousById(int rendezVousId) {
    for (final rendezVous in _rendezVous) {
      if (rendezVous.id == rendezVousId) {
        return rendezVous;
      }
    }

    return null;
  }

  Future<void> loadRendezVous({DateTime? dateDebut, DateTime? dateFin}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rendezVousDepuisApi = await repository.getRendezVous(
        dateDebut: dateDebut,
        dateFin: dateFin,
      );

      _rendezVous
        ..clear()
        ..addAll(rendezVousDepuisApi);

      _trierRendezVous();
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;
      await onUnauthorized();
    } catch (_) {
      _errorMessage = 'Impossible de charger les rendez-vous.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRendezVous(RendezVous rendezVous) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rendezVousCree = await repository.createRendezVous(rendezVous);

      _rendezVous.add(rendezVousCree);

      _trierRendezVous();

      return true;
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;
      await onUnauthorized();
      return false;
    } on RendezVousConflictException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Impossible de créer le rendez-vous.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateRendezVous(RendezVous rendezVous) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rendezVousMisAJour = await repository.updateRendezVous(rendezVous);

      final index = _rendezVous.indexWhere((element) {
        return element.id == rendezVousMisAJour.id;
      });

      if (index == -1) {
        _errorMessage = 'Le rendez-vous modifié est introuvable.';
        return false;
      }

      _rendezVous[index] = rendezVousMisAJour;

      _trierRendezVous();

      return true;
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;
      await onUnauthorized();
      return false;
    } on RendezVousConflictException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Impossible de modifier le rendez-vous.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRendezVous(int rendezVousId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteRendezVous(rendezVousId);

      _rendezVous.removeWhere((rendezVous) {
        return rendezVous.id == rendezVousId;
      });

      return true;
    } on UnauthorizedException catch (error) {
      _errorMessage = error.message;
      await onUnauthorized();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible de supprimer le rendez-vous.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearRendezVous() {
    _rendezVous.clear();
    _isLoading = false;
    _isSubmitting = false;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _trierRendezVous() {
    _rendezVous.sort((a, b) => a.dateHeureDebut.compareTo(b.dateHeureDebut));
  }

  bool _memeJour(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
