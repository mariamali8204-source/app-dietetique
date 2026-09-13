import '../../models/rendez_vous.dart';
import '../datasources/remote/rendez_vous_remote_data_source.dart';

class RendezVousRepository {
  RendezVousRepository({required this.remoteDataSource});

  final RendezVousRemoteDataSource remoteDataSource;

  Future<List<RendezVous>> getRendezVous({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) {
    return remoteDataSource.getRendezVous(
      dateDebut: dateDebut,
      dateFin: dateFin,
    );
  }

  Future<List<RendezVous>> getRendezVousDuJour(DateTime jour) {
    return remoteDataSource.getRendezVousDuJour(jour);
  }

  Future<RendezVous> getRendezVousById(int rendezVousId) {
    return remoteDataSource.getRendezVousById(rendezVousId);
  }

  Future<RendezVous> createRendezVous(RendezVous rendezVous) {
    return remoteDataSource.createRendezVous(rendezVous);
  }

  Future<RendezVous> updateRendezVous(RendezVous rendezVous) {
    return remoteDataSource.updateRendezVous(rendezVous);
  }

  Future<void> deleteRendezVous(int rendezVousId) {
    return remoteDataSource.deleteRendezVous(rendezVousId);
  }
}
