import 'package:flutter/foundation.dart';

import '../data/repositories/patient_repository.dart';
import '../models/patient.dart';

class PatientViewModel extends ChangeNotifier {
  PatientViewModel({required this.repository});

  final PatientRepository repository;

  final List<Patient> _patients = [];

  bool _isLoading = false;
  bool _isSubmitting = false;

  String? _errorMessage;

  List<Patient> get patients {
    return List.unmodifiable(_patients);
  }

  bool get isLoading {
    return _isLoading;
  }

  bool get isSubmitting {
    return _isSubmitting;
  }

  String? get errorMessage {
    return _errorMessage;
  }

  bool get hasError {
    return _errorMessage != null;
  }

  Future<void> loadPatients() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final patientsDepuisApi = await repository.getPatients();

      _patients
        ..clear()
        ..addAll(patientsDepuisApi);
    } catch (_) {
      _errorMessage = 'Impossible de charger les patients.';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<bool> addPatient(Patient patient) async {
    _isSubmitting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final patientCree = await repository.addPatient(patient);

      _patients.add(patientCree);

      return true;
    } catch (_) {
      _errorMessage = 'Impossible d’ajouter le patient.';

      return false;
    } finally {
      _isSubmitting = false;

      notifyListeners();
    }
  }

  Future<bool> updatePatient(Patient patient) async {
    _isSubmitting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final patientMisAJour = await repository.updatePatient(patient);

      final index = _patients.indexWhere((patientExistant) {
        return patientExistant.id == patientMisAJour.id;
      });

      if (index == -1) {
        _errorMessage = 'Le patient modifié est introuvable.';

        return false;
      }

      _patients[index] = patientMisAJour;

      return true;
    } catch (_) {
      _errorMessage = 'Impossible de modifier le patient.';

      return false;
    } finally {
      _isSubmitting = false;

      notifyListeners();
    }
  }

  Future<bool> deletePatient(int patientId) async {
    _isSubmitting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await repository.deletePatient(patientId);

      _patients.removeWhere((patient) {
        return patient.id == patientId;
      });

      return true;
    } catch (_) {
      _errorMessage = 'Impossible de supprimer le patient.';

      return false;
    } finally {
      _isSubmitting = false;

      notifyListeners();
    }
  }

  Patient? findPatientById(int patientId) {
    for (final patient in _patients) {
      if (patient.id == patientId) {
        return patient;
      }
    }

    return null;
  }

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}
