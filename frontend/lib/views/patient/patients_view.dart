import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/patient.dart';
import '../../viewmodels/health_view_model.dart';
import '../../viewmodels/patient_view_model.dart';
import 'ajouter_patient_view.dart';

class PatientsView extends StatefulWidget {
  const PatientsView({super.key});

  @override
  State<PatientsView> createState() {
    return _PatientsViewState();
  }
}

class _PatientsViewState extends State<PatientsView> {
  // =========================================================
  // ACTUALISER
  // =========================================================

  Future<void> _actualiser() async {
    final healthViewModel = context.read<HealthViewModel>();

    final patientViewModel = context.read<PatientViewModel>();

    await Future.wait([
      healthViewModel.checkBackend(),
      patientViewModel.loadPatients(),
    ]);
  }

  // =========================================================
  // PROFIL
  // =========================================================

  Future<void> _ouvrirProfilDieteticien() async {
    await Navigator.of(context).pushNamed<void>(AppRoutes.dietitianProfile);
  }

  // =========================================================
  // AJOUTER
  // =========================================================

  Future<void> _ajouterPatient() async {
    final nouveauPatient = await Navigator.of(context).push<Patient>(
      MaterialPageRoute<Patient>(
        builder: (context) {
          return const AjouterPatientView();
        },
      ),
    );

    if (!mounted || nouveauPatient == null) {
      return;
    }

    final patientViewModel = context.read<PatientViewModel>();

    final success = await patientViewModel.addPatient(nouveauPatient);

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient ajouté avec succès.')),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          patientViewModel.errorMessage ?? 'Erreur lors de l’ajout du patient.',
        ),
      ),
    );
  }

  // =========================================================
  // DOSSIER PATIENT
  // =========================================================

  Future<void> _ouvrirDossierPatient(Patient patientSelectionne) async {
    final resultat = await Navigator.of(context).pushNamed<dynamic>(
      AppRoutes.patientDetails,
      arguments: patientSelectionne,
    );

    if (!mounted) {
      return;
    }

    final patientViewModel = context.read<PatientViewModel>();

    // =======================================================
    // DELETE
    // =======================================================

    if (resultat == true) {
      final success = await patientViewModel.deletePatient(
        patientSelectionne.id,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient supprimé avec succès.')),
        );

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            patientViewModel.errorMessage ??
                'Erreur lors de la suppression du patient.',
          ),
        ),
      );

      return;
    }

    // =======================================================
    // UPDATE
    // =======================================================

    if (resultat is Patient) {
      final success = await patientViewModel.updatePatient(resultat);

      if (!mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient modifié avec succès.')),
        );

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            patientViewModel.errorMessage ??
                'Erreur lors de la modification du patient.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // PATIENT STATUS
  // =========================================================

  Color _couleurStatut(String statut) {
    if (statut == 'Actif') {
      return Colors.green;
    }

    if (statut == 'Suivi') {
      return Colors.orange;
    }

    return Colors.grey;
  }

  // =========================================================
  // BACKEND STATUS
  // =========================================================

  Color _couleurBackend(HealthViewModel healthViewModel) {
    if (healthViewModel.backendConnected == null) {
      return Colors.blueGrey;
    }

    if (healthViewModel.backendConnected == true) {
      return Colors.green;
    }

    return Colors.red;
  }

  IconData _iconeBackend(HealthViewModel healthViewModel) {
    if (healthViewModel.backendConnected == null) {
      return Icons.sync;
    }

    if (healthViewModel.backendConnected == true) {
      return Icons.cloud_done;
    }

    return Icons.cloud_off;
  }

  String _titreBackend(HealthViewModel healthViewModel) {
    if (healthViewModel.backendConnected == null) {
      return 'Connexion au backend';
    }

    if (healthViewModel.backendConnected == true) {
      return 'Backend connecté';
    }

    return 'Backend non connecté';
  }

  // =========================================================
  // CARTE BACKEND
  // =========================================================

  Widget _carteStatutBackend(HealthViewModel healthViewModel) {
    final couleur = _couleurBackend(healthViewModel);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: couleur.withValues(alpha: 0.12),
              child: healthViewModel.isChecking
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: couleur,
                      ),
                    )
                  : Icon(_iconeBackend(healthViewModel), color: couleur),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titreBackend(healthViewModel),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    healthViewModel.backendMessage,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: healthViewModel.isChecking ? null : _actualiser,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualiser',
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CARTE PATIENT
  // =========================================================

  Widget _cartePatient(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _couleurStatut(patient.statut),
          child: Text(
            patient.nom.isNotEmpty ? patient.nom[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(patient.nom),
        subtitle: Text(
          '${patient.objectifNutritionnel} • '
          '${patient.statut} • '
          '${patient.pays}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          _ouvrirDossierPatient(patient);
        },
      ),
    );
  }

  // =========================================================
  // CONTENU PATIENTS
  // =========================================================

  Widget _contenuPatients(PatientViewModel patientViewModel) {
    if (patientViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (patientViewModel.hasError && patientViewModel.patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              patientViewModel.errorMessage ?? 'Une erreur est survenue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: patientViewModel.loadPatients,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (patientViewModel.patients.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Aucun patient trouvé.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _actualiser,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: patientViewModel.patients.length,
        itemBuilder: (context, index) {
          final patient = patientViewModel.patients[index];

          return _cartePatient(patient);
        },
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Consumer2<PatientViewModel, HealthViewModel>(
      builder: (context, patientViewModel, healthViewModel, child) {
        return SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NutriCare Pro',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Patients',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _ouvrirProfilDieteticien,
                          icon: const Icon(Icons.account_circle, size: 30),
                          tooltip: 'Profil du diététicien',
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Liste des patients chargée '
                      'depuis le backend FastAPI.',
                    ),

                    const SizedBox(height: 16),

                    _carteStatutBackend(healthViewModel),

                    Expanded(child: _contenuPatients(patientViewModel)),
                  ],
                ),
              ),

              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  heroTag: 'ajouter_patient_button',
                  onPressed: patientViewModel.isSubmitting
                      ? null
                      : _ajouterPatient,
                  icon: patientViewModel.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1),
                  label: Text(
                    patientViewModel.isSubmitting ? 'Traitement...' : 'Ajouter',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
