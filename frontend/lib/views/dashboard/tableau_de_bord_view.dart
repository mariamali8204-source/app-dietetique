import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/patient_view_model.dart';

class TableauDeBordView extends StatelessWidget {
  const TableauDeBordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, PatientViewModel>(
      builder: (context, authViewModel, patientViewModel, child) {
        final patients = patientViewModel.patients;

        final patientsActifs = patients.where((patient) {
          return patient.statut.trim().toLowerCase() == 'actif';
        }).length;

        final patientsEnSuivi = patients.where((patient) {
          return patient.statut.trim().toLowerCase() == 'suivi';
        }).length;

        final patientsEnPause = patients.where((patient) {
          return patient.statut.trim().toLowerCase() == 'en pause';
        }).length;

        final patientsRecents = patients.reversed.take(3).toList();

        final nomUtilisateur = authViewModel.currentUser?.nom;

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: patientViewModel.loadPatients,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  nomUtilisateur == null
                      ? 'Tableau de bord'
                      : 'Bonjour, $nomUtilisateur',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Voici un aperçu de votre activité.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _StatCard(
                      icon: Icons.people_outline,
                      title: 'Patients',
                      value: '${patients.length}',
                    ),
                    _StatCard(
                      icon: Icons.check_circle_outline,
                      title: 'Patients actifs',
                      value: '$patientsActifs',
                    ),
                    _StatCard(
                      icon: Icons.monitor_heart_outlined,
                      title: 'En suivi',
                      value: '$patientsEnSuivi',
                    ),
                    _StatCard(
                      icon: Icons.pause_circle_outline,
                      title: 'En pause',
                      value: '$patientsEnPause',
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Text(
                  'Patients récents',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                if (patientViewModel.isLoading && patients.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (patientsRecents.isEmpty)
                  const _EmptyState()
                else
                  ...patientsRecents.map((patient) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            patient.nom.trim().isEmpty
                                ? '?'
                                : patient.nom.trim()[0].toUpperCase(),
                          ),
                        ),
                        title: Text(patient.nom),
                        subtitle: Text(patient.objectifNutritionnel),
                        trailing: _StatusChip(statut: patient.statut),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const Spacer(),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.statut});

  final String statut;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(statut), visualDensity: VisualDensity.compact);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Aucun patient pour le moment.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
