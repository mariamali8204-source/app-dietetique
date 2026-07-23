import 'package:flutter/material.dart';

import '../../models/patient.dart';

class DossierPatientView extends StatelessWidget {
  final Patient patient;

  const DossierPatientView({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dossier patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.nom,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text('Adresse e-mail : ${patient.email}'),
                Text('Pays : ${patient.pays}'),
                Text('Téléphone : ${patient.indicatif} ${patient.telephone}'),
                Text('Objectif : ${patient.objectifNutritionnel}'),
                Text('Statut : ${patient.statut}'),
                Text(
                  patient.notificationsAutorisees
                      ? 'Notifications : autorisées'
                      : 'Notifications : non autorisées',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}