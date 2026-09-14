import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/rendez_vous.dart';
import '../../viewmodels/patient_view_model.dart';
import '../../viewmodels/rendez_vous_view_model.dart';
import 'ajouter_rendez_vous_view.dart';

class RendezVousView extends StatefulWidget {
  const RendezVousView({super.key});

  @override
  State<RendezVousView> createState() {
    return _RendezVousViewState();
  }
}

class _RendezVousViewState extends State<RendezVousView> {
  DateTime _dateSelectionnee = DateTime.now();

  final TextEditingController _rechercheController = TextEditingController();

  String _recherche = '';

  DateTime get _dateNormalisee {
    return DateTime(
      _dateSelectionnee.year,
      _dateSelectionnee.month,
      _dateSelectionnee.day,
    );
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  Future<void> _ajouterRendezVous() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AjouterRendezVousView(dateInitiale: _dateNormalisee),
      ),
    );

    if (!mounted || result != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rendez-vous créé avec succès.')),
    );
  }

  Future<void> _modifierRendezVous(RendezVous rendezVous) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AjouterRendezVousView(
          dateInitiale: rendezVous.dateRendezVous,
          rendezVous: rendezVous,
        ),
      ),
    );

    if (!mounted || result != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rendez-vous modifié avec succès.')),
    );
  }

  Future<void> _annulerRendezVous(RendezVous rendezVous) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Annuler le rendez-vous'),
          content: const Text('Voulez-vous vraiment annuler ce rendez-vous ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Retour'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Annuler le rendez-vous'),
            ),
          ],
        );
      },
    );

    if (confirmer != true || !mounted) {
      return;
    }

    final rendezVousAnnule = RendezVous(
      id: rendezVous.id,
      userId: rendezVous.userId,
      patientId: rendezVous.patientId,
      dateRendezVous: rendezVous.dateRendezVous,
      heureDebut: rendezVous.heureDebut,
      heureFin: rendezVous.heureFin,
      motif: rendezVous.motif,
      typeRendezVous: rendezVous.typeRendezVous,
      statut: 'Annulé',
      rappelPatientActive: rendezVous.rappelPatientActive,
      notes: rendezVous.notes,
      createdAt: rendezVous.createdAt,
      updatedAt: DateTime.now(),
    );

    final viewModel = context.read<RendezVousViewModel>();

    final success = await viewModel.updateRendezVous(rendezVousAnnule);

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Impossible d’annuler le rendez-vous.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rendez-vous annulé.')));
  }

  Future<void> _supprimerRendezVous(RendezVous rendezVous) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le rendez-vous'),
          content: const Text(
            'Cette action est définitive. Voulez-vous continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmer != true || !mounted) {
      return;
    }

    final viewModel = context.read<RendezVousViewModel>();

    final success = await viewModel.deleteRendezVous(rendezVous.id);

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Impossible de supprimer le rendez-vous.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rendez-vous supprimé.')));
  }

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateNormalisee,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      helpText: 'Sélectionner une date',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );

    if (date == null) {
      return;
    }

    setState(() {
      _dateSelectionnee = date;
    });
  }

  void _jourPrecedent() {
    setState(() {
      _dateSelectionnee = _dateNormalisee.subtract(const Duration(days: 1));
    });
  }

  void _jourSuivant() {
    setState(() {
      _dateSelectionnee = _dateNormalisee.add(const Duration(days: 1));
    });
  }

  void _allerAujourdhui() {
    setState(() {
      _dateSelectionnee = DateTime.now();
    });
  }

  // =========================================================
  // RECHERCHE
  // =========================================================

  List<RendezVous> _filtrerRendezVous(
    List<RendezVous> rendezVous,
    PatientViewModel patientViewModel,
  ) {
    final recherche = _recherche.trim().toLowerCase();

    if (recherche.isEmpty) {
      return rendezVous;
    }

    return rendezVous.where((rendezVous) {
      final patientNom = _nomPatient(
        patientViewModel,
        rendezVous.patientId,
      ).toLowerCase();

      return patientNom.contains(recherche);
    }).toList();
  }

  void _viderRecherche() {
    _rechercheController.clear();

    setState(() {
      _recherche = '';
    });
  }

  Widget _barreRecherche() {
    return TextField(
      controller: _rechercheController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Rechercher par patient...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _recherche.isEmpty
            ? null
            : IconButton(
                onPressed: _viderRecherche,
                icon: const Icon(Icons.close),
                tooltip: 'Effacer la recherche',
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        setState(() {
          _recherche = value;
        });
      },
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Consumer2<RendezVousViewModel, PatientViewModel>(
      builder: (context, rendezVousViewModel, patientViewModel, child) {
        final rendezVousDuJour = rendezVousViewModel.rendezVousDuJour(
          _dateNormalisee,
        );

        final rendezVousFiltres = _filtrerRendezVous(
          rendezVousDuJour,
          patientViewModel,
        );

        return SafeArea(
          child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: rendezVousViewModel.isSubmitting
                  ? null
                  : _ajouterRendezVous,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nouveau rendez-vous'),
            ),
            body: RefreshIndicator(
              onRefresh: rendezVousViewModel.loadRendezVous,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
                children: [
                  _Header(
                    date: _dateNormalisee,
                    nombreRendezVous: rendezVousFiltres.length,
                    onPrevious: _jourPrecedent,
                    onNext: _jourSuivant,
                    onToday: _allerAujourdhui,
                    onCalendar: _choisirDate,
                  ),

                  const SizedBox(height: 20),

                  _SemaineSelector(
                    dateSelectionnee: _dateNormalisee,
                    onDateSelected: (date) {
                      setState(() {
                        _dateSelectionnee = date;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  _barreRecherche(),

                  const SizedBox(height: 24),

                  if (rendezVousViewModel.isLoading &&
                      rendezVousViewModel.rendezVous.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 70),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (rendezVousViewModel.hasError &&
                      rendezVousViewModel.rendezVous.isEmpty)
                    _EtatErreur(
                      message:
                          rendezVousViewModel.errorMessage ??
                          'Impossible de charger les rendez-vous.',
                      onRetry: rendezVousViewModel.loadRendezVous,
                    )
                  else if (rendezVousDuJour.isEmpty)
                    _EtatVide(estAujourdhui: _estAujourdhui(_dateNormalisee))
                  else if (rendezVousFiltres.isEmpty)
                    _AucunResultatRecherche(onEffacer: _viderRecherche)
                  else ...[
                    Text(
                      'Planning de la journée',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...rendezVousFiltres.map((rendezVous) {
                      return _RendezVousTimelineItem(
                        rendezVous: rendezVous,
                        patientNom: _nomPatient(
                          patientViewModel,
                          rendezVous.patientId,
                        ),
                        onModifier: () {
                          _modifierRendezVous(rendezVous);
                        },
                        onAnnuler: () {
                          _annulerRendezVous(rendezVous);
                        },
                        onSupprimer: () {
                          _supprimerRendezVous(rendezVous);
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _nomPatient(PatientViewModel viewModel, int patientId) {
    for (final patient in viewModel.patients) {
      if (patient.id == patientId) {
        return patient.nom;
      }
    }

    return 'Patient';
  }

  bool _estAujourdhui(DateTime date) {
    final maintenant = DateTime.now();

    return date.year == maintenant.year &&
        date.month == maintenant.month &&
        date.day == maintenant.day;
  }
}

// =========================================================
// HEADER
// =========================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.date,
    required this.nombreRendezVous,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onCalendar,
  });

  final DateTime date;
  final int nombreRendezVous;

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    final aujourdHui = _estAujourdhui(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rendez-vous',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aujourdHui
                        ? 'Votre planning d’aujourd’hui'
                        : 'Planning du ${_formatDateLongue(date)}',
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: onCalendar,
              tooltip: 'Choisir une date',
              icon: const Icon(Icons.calendar_month_outlined),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onPrevious,
                tooltip: 'Jour précédent',
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      aujourdHui ? 'Aujourd’hui' : _jourSemaine(date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(_formatDateLongue(date)),
                    const SizedBox(height: 7),
                    Text(
                      nombreRendezVous == 0
                          ? 'Aucun rendez-vous'
                          : nombreRendezVous == 1
                          ? '1 rendez-vous'
                          : '$nombreRendezVous rendez-vous',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onNext,
                tooltip: 'Jour suivant',
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),

        if (!aujourdHui) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onToday,
              icon: const Icon(Icons.today_outlined),
              label: const Text('Revenir à aujourd’hui'),
            ),
          ),
        ],
      ],
    );
  }

  static bool _estAujourdhui(DateTime date) {
    final maintenant = DateTime.now();

    return date.year == maintenant.year &&
        date.month == maintenant.month &&
        date.day == maintenant.day;
  }
}

// =========================================================
// SEMAINE
// =========================================================

class _SemaineSelector extends StatelessWidget {
  const _SemaineSelector({
    required this.dateSelectionnee,
    required this.onDateSelected,
  });

  final DateTime dateSelectionnee;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final lundi = dateSelectionnee.subtract(
      Duration(days: dateSelectionnee.weekday - 1),
    );

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = lundi.add(Duration(days: index));

          final selected = _memeJour(date, dateSelectionnee);

          final aujourdHui = _memeJour(date, DateTime.now());

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              onDateSelected(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: aujourdHui && !selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _jourCourt(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static bool _memeJour(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// =========================================================
// RENDEZ-VOUS CARD
// =========================================================

class _RendezVousTimelineItem extends StatelessWidget {
  const _RendezVousTimelineItem({
    required this.rendezVous,
    required this.patientNom,
    required this.onModifier,
    required this.onAnnuler,
    required this.onSupprimer,
  });

  final RendezVous rendezVous;
  final String patientNom;

  final VoidCallback onModifier;
  final VoidCallback onAnnuler;
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 62,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _heureCourte(rendezVous.heureDebut),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  _heureCourte(rendezVous.heureFin),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _couleurStatut(context, rendezVous.statut),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.grey.withValues(alpha: 0.18),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            patientNom,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),

                        _StatutChip(statut: rendezVous.statut),

                        PopupMenuButton<String>(
                          tooltip: 'Actions',
                          onSelected: (value) {
                            switch (value) {
                              case 'modifier':
                                onModifier();
                                break;

                              case 'annuler':
                                onAnnuler();
                                break;

                              case 'supprimer':
                                onSupprimer();
                                break;
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem(
                                value: 'modifier',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(Icons.edit_outlined),
                                  title: Text('Modifier'),
                                ),
                              ),

                              if (!rendezVous.estAnnule &&
                                  !rendezVous.estTermine)
                                const PopupMenuItem(
                                  value: 'annuler',
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.event_busy_outlined),
                                    title: Text('Annuler'),
                                  ),
                                ),

                              const PopupMenuDivider(),

                              const PopupMenuItem(
                                value: 'supprimer',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(Icons.delete_outline),
                                  title: Text('Supprimer'),
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        const Icon(
                          Icons.medical_information_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Expanded(child: Text(rendezVous.motif)),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Icon(
                          rendezVous.typeRendezVous == 'En ligne'
                              ? Icons.videocam_outlined
                              : Icons.location_on_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Text(rendezVous.typeRendezVous),
                        const Spacer(),
                        const Icon(Icons.schedule_outlined, size: 17),
                        const SizedBox(width: 5),
                        Text(_formatDuree(rendezVous.duree)),
                      ],
                    ),

                    if (rendezVous.rappelPatientActive) ...[
                      const SizedBox(height: 9),
                      const Row(
                        children: [
                          Icon(Icons.notifications_active_outlined, size: 17),
                          SizedBox(width: 7),
                          Text('Rappel patient activé'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// STATUT
// =========================================================

class _StatutChip extends StatelessWidget {
  const _StatutChip({required this.statut});

  final String statut;

  @override
  Widget build(BuildContext context) {
    final color = _couleurStatut(context, statut);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        statut,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =========================================================
// AUCUN RESULTAT RECHERCHE
// =========================================================

class _AucunResultatRecherche extends StatelessWidget {
  const _AucunResultatRecherche({required this.onEffacer});

  final VoidCallback onEffacer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 55),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 56, color: Colors.grey),
          const SizedBox(height: 14),
          Text(
            'Aucun rendez-vous trouvé',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          const Text(
            'Aucun rendez-vous ne correspond à ce patient pour cette journée.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onEffacer,
            icon: const Icon(Icons.close),
            label: const Text('Effacer la recherche'),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// ETAT VIDE
// =========================================================

class _EtatVide extends StatelessWidget {
  const _EtatVide({required this.estAujourdhui});

  final bool estAujourdhui;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 55),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_available_outlined, size: 42),
          ),
          const SizedBox(height: 18),
          Text(
            estAujourdhui
                ? 'Aucun rendez-vous aujourd’hui'
                : 'Aucun rendez-vous ce jour',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          const Text(
            'Votre planning est libre pour cette journée.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =========================================================
// ERREUR
// =========================================================

class _EtatErreur extends StatelessWidget {
  const _EtatErreur({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 55),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              onRetry();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// HELPERS
// =========================================================

Color _couleurStatut(BuildContext context, String statut) {
  switch (statut) {
    case 'Confirmé':
      return Colors.green;

    case 'Terminé':
      return Colors.blue;

    case 'Annulé':
      return Colors.red;

    case 'Absent':
      return Colors.orange;

    case 'Planifié':
    default:
      return Theme.of(context).colorScheme.primary;
  }
}

String _heureCourte(String heure) {
  if (heure.length >= 5) {
    return heure.substring(0, 5);
  }

  return heure;
}

String _formatDuree(Duration duree) {
  final minutes = duree.inMinutes;

  if (minutes < 60) {
    return '$minutes min';
  }

  final heures = minutes ~/ 60;

  final reste = minutes % 60;

  if (reste == 0) {
    return '$heures h';
  }

  return '$heures h $reste min';
}

String _jourCourt(DateTime date) {
  const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  return jours[date.weekday - 1];
}

String _jourSemaine(DateTime date) {
  const jours = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  return jours[date.weekday - 1];
}

String _formatDateLongue(DateTime date) {
  const mois = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  return '${date.day} ${mois[date.month - 1]} ${date.year}';
}
