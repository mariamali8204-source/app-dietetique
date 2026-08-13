import 'package:flutter/material.dart';

import '../../models/patient.dart';
import 'modifier_patient_view.dart';

class DossierPatientView extends StatefulWidget {
  final Patient patient;

  const DossierPatientView({super.key, required this.patient});

  @override
  State<DossierPatientView> createState() {
    return _DossierPatientViewState();
  }
}

class _DossierPatientViewState extends State<DossierPatientView> {
  late Patient _patient;

  @override
  void initState() {
    super.initState();

    _patient = widget.patient;
  }

  // =========================================================
  // FORMAT DATE
  // =========================================================

  String _formatDate(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');

    final mois = date.month.toString().padLeft(2, '0');

    final annee = date.year.toString();

    return '$jour/$mois/$annee';
  }

  // =========================================================
  // COULEUR STATUT
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
  // MODIFIER PATIENT
  // =========================================================

  Future<void> _modifierPatient() async {
    final patientModifie = await Navigator.of(context).push<Patient>(
      MaterialPageRoute<Patient>(
        builder: (context) {
          return ModifierPatientView(patient: _patient);
        },
      ),
    );

    if (!mounted) {
      return;
    }

    if (patientModifie == null) {
      return;
    }

    // La View ne fait aucun PUT.
    // Elle retourne simplement le patient modifié.
    Navigator.of(context).pop(patientModifie);
  }

  // =========================================================
  // CONFIRMATION SUPPRESSION
  // =========================================================

  Future<void> _confirmerSuppression() async {
    final confirmation = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, size: 42),
          title: const Text('Supprimer le patient'),
          content: const Text('Voulez-vous vraiment supprimer ce patient ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Supprimer'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (confirmation != true) {
      return;
    }

    // IMPORTANT :
    // Aucun appel API ici.
    // On informe seulement PatientsView
    // que l'utilisateur veut supprimer le patient.
    Navigator.of(context).pop(true);
  }

  // =========================================================
  // LIGNE INFORMATION
  // =========================================================

  Widget _ligneInformation({
    required IconData icon,
    required String titre,
    required String valeur,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  valeur,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SECTION
  // =========================================================

  Widget _section({required String titre, required List<Widget> enfants}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 10),
            ...enfants,
          ],
        ),
      ),
    );
  }

  // =========================================================
  // BADGE STATUT
  // =========================================================

  Widget _badgeStatut() {
    final couleur = _couleurStatut(_patient.statut);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _patient.statut,
        style: TextStyle(color: couleur, fontWeight: FontWeight.bold),
      ),
    );
  }

  // =========================================================
  // ENTÊTE PATIENT
  // =========================================================

  Widget _entetePatient() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: _couleurStatut(_patient.statut),
              child: Text(
                _patient.nom.isNotEmpty ? _patient.nom[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _patient.nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _patient.email,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  _badgeStatut(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      appBar: AppBar(
        title: const Text('Dossier patient'),
        backgroundColor: const Color(0xFFF6FAF8),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _entetePatient(),

            _section(
              titre: 'Informations personnelles',
              enfants: [
                _ligneInformation(
                  icon: Icons.person,
                  titre: 'Nom complet',
                  valeur: _patient.nom,
                ),
                _ligneInformation(
                  icon: Icons.email,
                  titre: 'Adresse e-mail',
                  valeur: _patient.email,
                ),
                _ligneInformation(
                  icon: Icons.public,
                  titre: 'Pays',
                  valeur: _patient.pays,
                ),
                _ligneInformation(
                  icon: Icons.phone,
                  titre: 'Téléphone',
                  valeur: _patient.telephoneComplet,
                ),
              ],
            ),

            _section(
              titre: 'Suivi nutritionnel',
              enfants: [
                _ligneInformation(
                  icon: Icons.flag,
                  titre: 'Objectif nutritionnel',
                  valeur: _patient.objectifNutritionnel,
                ),
                _ligneInformation(
                  icon: Icons.check_circle,
                  titre: 'Statut',
                  valeur: _patient.statut,
                ),
              ],
            ),

            _section(
              titre: 'Notifications',
              enfants: [
                _ligneInformation(
                  icon: Icons.notifications,
                  titre: 'Notifications autorisées',
                  valeur: _patient.notificationsAutorisees ? 'Oui' : 'Non',
                ),
              ],
            ),

            _section(
              titre: 'Informations système',
              enfants: [
                _ligneInformation(
                  icon: Icons.numbers,
                  titre: 'Identifiant patient',
                  valeur: _patient.id.toString(),
                ),
                _ligneInformation(
                  icon: Icons.calendar_today,
                  titre: 'Date de création',
                  valeur: _formatDate(_patient.createdAt),
                ),
                _ligneInformation(
                  icon: Icons.update,
                  titre: 'Dernière modification',
                  valeur: _formatDate(_patient.updatedAt),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _modifierPatient,
                icon: const Icon(Icons.edit),
                label: const Text('Modifier'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmerSuppression,
                icon: const Icon(Icons.delete),
                label: const Text('Supprimer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
