import '../../models/patient.dart';
import '../datasources/remote/patient_remote_data_source.dart';

class PatientRepository {
  PatientRepository({required this.remoteDataSource});

  final PatientRemoteDataSource remoteDataSource;

  Future<List<Patient>> getPatients() {
    return remoteDataSource.getPatients();
  }

  Future<Patient> addPatient(Patient patient) {
    return remoteDataSource.addPatient(patient);
  }

  Future<Patient> updatePatient(Patient patient) {
    return remoteDataSource.updatePatient(patient);
  }

  Future<void> deletePatient(int patientId) {
    return remoteDataSource.deletePatient(patientId);
  }
}
