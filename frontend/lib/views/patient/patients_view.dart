import 'package:flutter/material.dart';

import '../../models/patient.dart';
import '../../services/health_service.dart';
import '../../services/patient_service.dart';
import 'ajouter_patient_view.dart';
import 'dossier_patient_view.dart';

class PatientsView extends StatefulWidget {
  const PatientsView({super.key});

  @override
  State<PatientsView> createState() => _PatientsViewState();
}

class _PatientsViewState extends State<PatientsView> {
  final HealthService _healthService = HealthService();
  final PatientService _patientService = PatientService();

  bool? _backendConnected;
  String _backendMessage = 'Vérification de la connexion...';

  bool _isLoadingPatients = true;
  String? _patientsError;

  List<Patient> patients = [];

  @override
  void initState() {
    super.initState();
    _verifierBackend();
    _chargerPatients();
  }

  Future<void> _verifierBackend() async {
    setState(() {
      _backendConnected = null;
      _backendMessage = 'Vérification de la connexion...';
    });

    final result = await _healthService.checkHealth();

    if (!mounted) return;

    setState(() {
      _backendConnected = result.isConnected;
      _backendMessage = result.message;
    });
  }

  Future<void> _chargerPatients() async {
    setState(() {
      _isLoadingPatients = true;
      _patientsError = null;
    });

    try {
      final patientsDepuisApi = await _patientService.getPatients();

      if (!mounted) return;

      setState(() {
        patients = patientsDepuisApi;
        _isLoadingPatients = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingPatients = false;
        _patientsError = 'Impossible de charger les patients';
      });
    }
  }

  Future<void> _actualiser() async {
    await _verifierBackend();
    await _chargerPatients();
  }

  Future<void> _ajouterPatient() async {
    final nouveauPatient = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(
        builder: (context) => const AjouterPatientView(),
      ),
    );

    if (!mounted) return;

    if (nouveauPatient != null) {
      setState(() {
        patients.add(
          Patient(
            id: patients.length + 1,
            userId: nouveauPatient.userId,
            nom: nouveauPatient.nom,
            email: nouveauPatient.email,
            pays: nouveauPatient.pays,
            indicatif: nouveauPatient.indicatif,
            telephone: nouveauPatient.telephone,
            objectifNutritionnel: nouveauPatient.objectifNutritionnel,
            statut: nouveauPatient.statut,
            notificationsAutorisees: nouveauPatient.notificationsAutorisees,
            createdAt: nouveauPatient.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient ajouté localement'),
        ),
      );
    }
  }

  Future<void> _ouvrirDossierPatient(int index) async {
    final patientModifie = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(
        builder: (context) => DossierPatientView(
          patient: patients[index],
        ),
      ),
    );

    if (!mounted) return;

    if (patientModifie != null) {
      setState(() {
        patients[index] = patientModifie;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient modifié localement'),
        ),
      );
    }
  }

  Color _couleurStatut(String statut) {
    if (statut == 'Actif') {
      return Colors.green;
    } else if (statut == 'Suivi') {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  Color _couleurBackend() {
    if (_backendConnected == null) {
      return Colors.blueGrey;
    }

    if (_backendConnected == true) {
      return Colors.green;
    }

    return Colors.red;
  }

  IconData _iconeBackend() {
    if (_backendConnected == null) {
      return Icons.sync;
    }

    if (_backendConnected == true) {
      return Icons.cloud_done;
    }

    return Icons.cloud_off;
  }

  String _titreBackend() {
    if (_backendConnected == null) {
      return 'Connexion au backend';
    }

    if (_backendConnected == true) {
      return 'Backend connecté';
    }

    return 'Backend non connecté';
  }

  Widget _carteStatutBackend() {
    final couleur = _couleurBackend();

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: couleur.withValues(alpha: 0.12),
              child: Icon(
                _iconeBackend(),
                color: couleur,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titreBackend(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _backendMessage,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: _actualiser,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualiser',
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartePatient(Patient patient, int index) {
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
          '${patient.objectifNutritionnel} • ${patient.statut} • ${patient.pays}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          _ouvrirDossierPatient(index);
        },
      ),
    );
  }

  Widget _contenuPatients() {
    if (_isLoadingPatients) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_patientsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_patientsError!),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _chargerPatients,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (patients.isEmpty) {
      return const Center(
        child: Text('Aucun patient trouvé'),
      );
    }

    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context, index) {
        return _cartePatient(patients[index], index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      appBar: AppBar(
        title: const Text('NutriCare Pro'),
        backgroundColor: const Color(0xFFF6FAF8),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patients',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Liste des patients chargée depuis le backend FastAPI.',
            ),
            const SizedBox(height: 16),

            _carteStatutBackend(),

            Expanded(
              child: _contenuPatients(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterPatient,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}