import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/plan_nutritionnel.dart';
import '../../viewmodels/patient_view_model.dart';
import '../../viewmodels/plan_nutritionnel_view_model.dart';
import '../../viewmodels/programme_plan_view_model.dart';
import 'ajouter_plan_nutritionnel_view.dart';
import 'programme_plan_view.dart';

class PlansNutritionnelsView extends StatefulWidget {
  const PlansNutritionnelsView({super.key});

  @override
  State<PlansNutritionnelsView> createState() {
    return _PlansNutritionnelsViewState();
  }
}

class _PlansNutritionnelsViewState extends State<PlansNutritionnelsView> {
  final TextEditingController _rechercheController = TextEditingController();

  String _recherche = '';

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  // =========================================================
  // AJOUTER
  // =========================================================

  Future<void> _ajouterPlan(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AjouterPlanNutritionnelView()),
    );

    if (!context.mounted || result != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan nutritionnel créé avec succès.')),
    );
  }

  // =========================================================
  // MODIFIER
  // =========================================================

  Future<void> _modifierPlan(
    BuildContext context,
    PlanNutritionnel plan,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AjouterPlanNutritionnelView(planAModifier: plan),
      ),
    );

    if (!context.mounted || result != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan nutritionnel modifié avec succès.')),
    );
  }

  // =========================================================
  // OUVRIR PROGRAMME
  // =========================================================

  void _ouvrirProgramme(BuildContext context, PlanNutritionnel plan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProgrammePlanView(plan: plan)),
    );
  }

  // =========================================================
  // SUPPRIMER
  // =========================================================

  Future<void> _supprimerPlan(
    BuildContext context,
    PlanNutritionnel plan,
  ) async {
    final confirmation = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: 30,
            ),
          ),
          title: const Text('Supprimer ce plan ?', textAlign: TextAlign.center),
          content: Text(
            'Le plan « ${plan.titre} », son programme de 14 jours '
            'et tous les repas associés seront définitivement supprimés.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
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

    if (!context.mounted || confirmation != true) {
      return;
    }

    final viewModel = context.read<PlanNutritionnelViewModel>();

    final success = await viewModel.deletePlan(plan.id);

    if (!context.mounted) {
      return;
    }

    if (success) {
      final programmeViewModel = context.read<ProgrammePlanViewModel>();

      if (programmeViewModel.programme?.planId == plan.id) {
        programmeViewModel.clearProgramme();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan nutritionnel supprimé avec succès.'),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ??
              'Impossible de supprimer le plan nutritionnel.',
        ),
      ),
    );
  }

  // =========================================================
  // NOM PATIENT
  // =========================================================

  String _nomPatient(PatientViewModel viewModel, int patientId) {
    for (final patient in viewModel.patients) {
      if (patient.id == patientId) {
        return patient.nom;
      }
    }

    return 'Patient';
  }

  // =========================================================
  // RECHERCHE
  // =========================================================

  List<PlanNutritionnel> _filtrerPlans(
    List<PlanNutritionnel> plans,
    PatientViewModel patientViewModel,
  ) {
    final recherche = _recherche.trim().toLowerCase();

    if (recherche.isEmpty) {
      return plans;
    }

    return plans.where((plan) {
      final patientNom = _nomPatient(
        patientViewModel,
        plan.patientId,
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
    return Consumer2<PlanNutritionnelViewModel, PatientViewModel>(
      builder: (context, planViewModel, patientViewModel, child) {
        final plans = planViewModel.plans;

        final plansFiltres = _filtrerPlans(plans, patientViewModel);

        return SafeArea(
          child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: planViewModel.isSubmitting
                  ? null
                  : () => _ajouterPlan(context),
              icon: const Icon(Icons.add),
              label: const Text('Nouveau plan'),
            ),
            body: RefreshIndicator(
              onRefresh: planViewModel.loadPlans,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
                children: [
                  Text(
                    'Plans nutritionnels',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Créez et suivez les programmes alimentaires personnalisés de vos patients.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  _barreRecherche(),

                  const SizedBox(height: 22),

                  if (planViewModel.isLoading && plans.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (planViewModel.hasError && plans.isEmpty)
                    _ErreurPlans(
                      message:
                          planViewModel.errorMessage ??
                          'Impossible de charger les plans nutritionnels.',
                      onRetry: planViewModel.loadPlans,
                    )
                  else if (plans.isEmpty)
                    const _EtatVide()
                  else if (plansFiltres.isEmpty)
                    _AucunResultatRecherche(onEffacer: _viderRecherche)
                  else
                    ...plansFiltres.map((plan) {
                      final patientNom = _nomPatient(
                        patientViewModel,
                        plan.patientId,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _PlanCard(
                          plan: plan,
                          patientNom: patientNom,
                          isSubmitting: planViewModel.isSubmitting,
                          onOpen: () {
                            _ouvrirProgramme(context, plan);
                          },
                          onEdit: () {
                            _modifierPlan(context, plan);
                          },
                          onDelete: () {
                            _supprimerPlan(context, plan);
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// =========================================================
// PLAN CARD
// =========================================================

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.patientNom,
    required this.isSubmitting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final PlanNutritionnel plan;
  final String patientNom;
  final bool isSubmitting;

  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: isSubmitting ? null : onOpen,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.restaurant_menu_rounded),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.titre,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(patientNom),
                      ],
                    ),
                  ),

                  PopupMenuButton<_PlanAction>(
                    enabled: !isSubmitting,
                    tooltip: 'Actions du plan',
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (action) {
                      switch (action) {
                        case _PlanAction.modifier:
                          onEdit();
                          break;

                        case _PlanAction.supprimer:
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem<_PlanAction>(
                          value: _PlanAction.modifier,
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 10),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        PopupMenuItem<_PlanAction>(
                          value: _PlanAction.supprimer,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Supprimer',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: Icon(_iconeStatut(plan.statut), size: 17),
                  label: Text(plan.statut),
                  visualDensity: VisualDensity.compact,
                ),
              ),

              const SizedBox(height: 12),

              _LigneInfo(icon: Icons.flag_outlined, text: plan.objectif),

              if (plan.caloriesJournalieres != null) ...[
                const SizedBox(height: 8),
                _LigneInfo(
                  icon: Icons.local_fire_department_outlined,
                  text: '${plan.caloriesJournalieres} kcal / jour',
                ),
              ],

              const SizedBox(height: 8),

              const _LigneInfo(
                icon: Icons.date_range_outlined,
                text: 'Programme sur 14 jours',
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: isSubmitting ? null : onOpen,
                  icon: const Icon(Icons.calendar_view_week_outlined),
                  label: const Text('Ouvrir le programme'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PlanAction { modifier, supprimer }

// =========================================================
// LIGNE INFO
// =========================================================

class _LigneInfo extends StatelessWidget {
  const _LigneInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

// =========================================================
// ETAT VIDE
// =========================================================

class _EtatVide extends StatelessWidget {
  const _EtatVide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_menu_rounded, size: 42),
          ),
          const SizedBox(height: 18),
          Text(
            'Aucun plan nutritionnel',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 7),
          const Text(
            'Créez le premier programme alimentaire personnalisé pour votre patient.',
            textAlign: TextAlign.center,
          ),
        ],
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
            'Aucun plan trouvé',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 7),
          const Text(
            'Aucun plan ne correspond à ce patient.',
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
// ERREUR
// =========================================================

class _ErreurPlans extends StatelessWidget {
  const _ErreurPlans({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 58),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// ICONE STATUT
// =========================================================

IconData _iconeStatut(String statut) {
  switch (statut.toLowerCase()) {
    case 'actif':
      return Icons.check_circle_outline;

    case 'en pause':
      return Icons.pause_circle_outline;

    case 'terminé':
      return Icons.task_alt_outlined;

    default:
      return Icons.info_outline;
  }
}
