import '../models/patient.dart';

class PatientService {
  Future<List<Patient>> getPatients() async {
    return [];
  }

  Future<Patient?> getPatientById(int id) async {
    return null;
  }

  Future<void> createPatient(Patient patient) async {}

  Future<void> updatePatient(Patient patient) async {}

  Future<void> deletePatient(int id) async {}
}