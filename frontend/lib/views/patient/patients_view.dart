import 'package:flutter/material.dart';

import '../../models/patient.dart';
import 'ajouter_patient_view.dart';
import 'dossier_patient_view.dart';

class PatientsView extends StatefulWidget {
  const PatientsView({super.key});

  @override
  State<PatientsView> createState() => _PatientsViewState();
}

class _PatientsViewState extends State<PatientsView> {
  final List<Patient> patients = [
    Patient(
      id: 1,
      userId: 1,
      nom: 'Mariam Ali',
      email: 'mariam.ali@gmail.com',
      pays: 'Liban',
      indicatif: '+961',
      telephone: '70123456',
      objectifNutritionnel: 'Perte de poids',
      statut: 'Actif',
      notificationsAutorisees: true,
      createdAt: DateTime(2026, 7, 23),
      updatedAt: DateTime(2026, 7, 23),
    ),
    Patient(
      id: 2,
      userId: 1,
      nom: 'Sally Ahmad',
      email: 'sally.ahmad@email.com',
      pays: 'Liban',
      indicatif: '+961',
      telephone: '71123456',
      objectifNutritionnel: 'Nutrition équilibrée',
      statut: 'Suivi',
      notificationsAutorisees: true,
      createdAt: DateTime(2026, 7, 23),
      updatedAt: DateTime(2026, 7, 23),
    ),
    Patient(
      id: 3,
      userId: 1,
      nom: 'Nour Hassan',
      email: 'nour.hassan@email.com',
      pays: 'Liban',
      indicatif: '+961',
      telephone: '76123456',
      objectifNutritionnel: 'Maintien du poids',
      statut: 'En pause',
      notificationsAutorisees: false,
      createdAt: DateTime(2026, 7, 23),
      updatedAt: DateTime(2026, 7, 23),
    ),
  ];

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
            updatedAt: nouveauPatient.updatedAt,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient ajouté avec succès'),
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
          content: Text('Patient modifié avec succès'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriCare Pro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patients',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Liste dynamique des patients suivis par le diététicien.',
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _couleurStatut(patient.statut),
                        child: Text(
                          patient.nom.isNotEmpty
                              ? patient.nom[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(patient.nom),
                      subtitle: Text(
                        '${patient.objectifNutritionnel} • ${patient.statut}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _ouvrirDossierPatient(index);
                      },
                    ),
                  );
                },
              ),
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