import 'package:flutter/material.dart';

import '../../models/patient.dart';
import 'modifier_patient_view.dart';

class DossierPatientView extends StatelessWidget {
  final Patient patient;

  const DossierPatientView({
    super.key,
    required this.patient,
  });

  Future<void> _modifierPatient(BuildContext context) async {
    final patientModifie = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(
        builder: (context) => ModifierPatientView(patient: patient),
      ),
    );

    if (!context.mounted) return;

    if (patientModifie != null) {
      Navigator.pop(context, patientModifie);
    }
  }

  Widget _ligneInformation(String titre, String valeur) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(titre),
        subtitle: Text(valeur),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dossier patient'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(
                        patient.nom.isNotEmpty
                            ? patient.nom[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.nom,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(patient.objectifNutritionnel),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(patient.statut),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Informations personnelles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            _ligneInformation('Adresse e-mail', patient.email),
            _ligneInformation('Pays', patient.pays),
            _ligneInformation(
              'Téléphone',
              '${patient.indicatif} ${patient.telephone}',
            ),

            const SizedBox(height: 20),

            Text(
              'Suivi nutritionnel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            _ligneInformation(
              'Objectif nutritionnel',
              patient.objectifNutritionnel,
            ),
            _ligneInformation('Statut du patient', patient.statut),
            _ligneInformation(
              'Notifications',
              patient.notificationsAutorisees
                  ? 'Autorisées'
                  : 'Non autorisées',
            ),

            const SizedBox(height: 20),

            Text(
              'Traçabilité',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            _ligneInformation(
              'Date de création',
              patient.createdAt != null
                  ? patient.createdAt.toString()
                  : 'Non définie',
            ),
            _ligneInformation(
              'Dernière modification',
              patient.updatedAt != null
                  ? patient.updatedAt.toString()
                  : 'Non définie',
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _modifierPatient(context);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Modifier'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}