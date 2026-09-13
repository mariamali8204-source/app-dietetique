import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/plan_nutritionnel.dart';
import '../../models/programme_plan.dart';
import '../../viewmodels/programme_plan_view_model.dart';

class ProgrammePlanView extends StatefulWidget {
  const ProgrammePlanView({super.key, required this.plan});

  final PlanNutritionnel plan;

  @override
  State<ProgrammePlanView> createState() => _ProgrammePlanViewState();
}

class _ProgrammePlanViewState extends State<ProgrammePlanView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final viewModel = context.read<ProgrammePlanViewModel>();

      viewModel.clearProgramme();
      viewModel.loadProgramme(widget.plan.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Programme alimentaire'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semaine 1'),
              Tab(text: 'Semaine 2'),
            ],
          ),
        ),
        body: Consumer<ProgrammePlanViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.programme == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.hasError && viewModel.programme == null) {
              return _ErreurProgramme(
                message: viewModel.errorMessage ?? 'Une erreur est survenue.',
                onRetry: () {
                  viewModel.loadProgramme(widget.plan.id);
                },
              );
            }

            final programme = viewModel.programme;

            if (programme == null) {
              return const Center(child: Text('Programme indisponible.'));
            }

            return Column(
              children: [
                _EntetePlan(plan: widget.plan),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ListeSemaine(
                        planId: widget.plan.id,
                        jours: programme.semaine1,
                      ),
                      _ListeSemaine(
                        planId: widget.plan.id,
                        jours: programme.semaine2,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EntetePlan extends StatelessWidget {
  const _EntetePlan({required this.plan});

  final PlanNutritionnel plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.titre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('Programme personnalisé sur 14 jours'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(icon: Icons.flag_outlined, text: plan.objectif),
              if (plan.caloriesJournalieres != null)
                _InfoPill(
                  icon: Icons.local_fire_department_outlined,
                  text: '${plan.caloriesJournalieres} kcal/jour',
                ),
              _InfoPill(
                icon: Icons.calendar_today_outlined,
                text:
                    '${_formatDate(plan.dateDebut)}'
                    ' → '
                    '${plan.dateFin == null ? '-' : _formatDate(plan.dateFin!)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListeSemaine extends StatelessWidget {
  const _ListeSemaine({required this.planId, required this.jours});

  final int planId;
  final List<PlanJour> jours;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return context.read<ProgrammePlanViewModel>().loadProgramme(planId);
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        itemCount: jours.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          return _JourCard(planId: planId, jour: jours[index]);
        },
      ),
    );
  }
}

class _JourCard extends StatelessWidget {
  const _JourCard({required this.planId, required this.jour});

  final int planId;
  final PlanJour jour;

  @override
  Widget build(BuildContext context) {
    final repasCompletes = jour.repas.where((repas) {
      return repas.contenu.trim().isNotEmpty;
    }).length;

    final progression = jour.repas.isEmpty
        ? 0.0
        : repasCompletes / jour.repas.length;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        leading: CircleAvatar(
          child: Text(
            '${jour.numeroJour}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'Jour ${jour.numeroJour}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              jour.dateJour == null
                  ? 'Date non définie'
                  : _formatDate(jour.dateJour!),
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progression, minHeight: 5),
            ),
            const SizedBox(height: 4),
            Text(
              '$repasCompletes/${jour.repas.length} repas complétés',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        children: [
          ...jour.repas.map((repas) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RepasCard(planId: planId, repas: repas),
            );
          }),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () {
                _ouvrirEditionJour(context, planId, jour);
              },
              icon: const Icon(Icons.monitor_heart_outlined),
              label: const Text('Hydratation, activité et recommandations'),
            ),
          ),
          if (_jourAInformations(jour)) ...[
            const SizedBox(height: 12),
            _ResumeJour(jour: jour),
          ],
        ],
      ),
    );
  }
}

class _RepasCard extends StatelessWidget {
  const _RepasCard({required this.planId, required this.repas});

  final int planId;
  final PlanRepas repas;

  @override
  Widget build(BuildContext context) {
    final estComplete = repas.contenu.trim().isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        _ouvrirEditionRepas(context, planId, repas);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(_mealIcon(repas.typeRepas)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          repas.typeRepas,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(
                        estComplete ? Icons.check_circle : Icons.edit_outlined,
                        size: 20,
                        color: estComplete
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (!estComplete)
                    Text(
                      'Appuyez pour renseigner le repas',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else ...[
                    Text(
                      repas.contenu,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 5,
                      children: [
                        if (repas.heure != null)
                          _MiniInfo(
                            icon: Icons.schedule_outlined,
                            text: _formatHeure(repas.heure!),
                          ),
                        if (repas.calories != null)
                          _MiniInfo(
                            icon: Icons.local_fire_department_outlined,
                            text: '${repas.calories} kcal',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ResumeJour extends StatelessWidget {
  const _ResumeJour({required this.jour});

  final PlanJour jour;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.tertiaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasValue(jour.hydratation))
            _ResumeLigne(
              icon: Icons.water_drop_outlined,
              label: 'Hydratation',
              value: jour.hydratation!,
            ),
          if (_hasValue(jour.activitePhysique))
            _ResumeLigne(
              icon: Icons.directions_walk,
              label: 'Activité physique',
              value: jour.activitePhysique!,
            ),
          if (_hasValue(jour.recommandations))
            _ResumeLigne(
              icon: Icons.lightbulb_outline,
              label: 'Recommandations',
              value: jour.recommandations!,
            ),
        ],
      ),
    );
  }
}

class _ResumeLigne extends StatelessWidget {
  const _ResumeLigne({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('$label : $value')),
        ],
      ),
    );
  }
}

Future<void> _ouvrirEditionRepas(
  BuildContext context,
  int planId,
  PlanRepas repas,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) {
      return _RepasEditor(planId: planId, repas: repas);
    },
  );

  if (!context.mounted || result != true) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${repas.typeRepas} enregistré avec succès.')),
  );
}

class _RepasEditor extends StatefulWidget {
  const _RepasEditor({required this.planId, required this.repas});

  final int planId;
  final PlanRepas repas;

  @override
  State<_RepasEditor> createState() => _RepasEditorState();
}

class _RepasEditorState extends State<_RepasEditor> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _contenuController;

  late final TextEditingController _caloriesController;

  late final TextEditingController _notesController;

  TimeOfDay? _heure;

  @override
  void initState() {
    super.initState();

    _contenuController = TextEditingController(text: widget.repas.contenu);

    _caloriesController = TextEditingController(
      text: widget.repas.calories?.toString() ?? '',
    );

    _notesController = TextEditingController(text: widget.repas.notes ?? '');

    _heure = _parseHeure(widget.repas.heure);
  }

  @override
  void dispose() {
    _contenuController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _selectionnerHeure() async {
    final heure = await showTimePicker(
      context: context,
      initialTime: _heure ?? const TimeOfDay(hour: 8, minute: 0),
    );

    if (heure != null) {
      setState(() {
        _heure = heure;
      });
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final caloriesText = _caloriesController.text.trim();

    final repasMisAJour = PlanRepas(
      id: widget.repas.id,
      jourId: widget.repas.jourId,
      typeRepas: widget.repas.typeRepas,
      heure: _heure == null ? null : _apiHeure(_heure!),
      contenu: _contenuController.text.trim(),
      calories: caloriesText.isEmpty ? null : int.parse(caloriesText),
      ordre: widget.repas.ordre,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.repas.createdAt,
      updatedAt: widget.repas.updatedAt,
    );

    final success = await context.read<ProgrammePlanViewModel>().updateRepas(
      planId: widget.planId,
      repas: repasMisAJour,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<ProgrammePlanViewModel>().errorMessage ??
              'Impossible d’enregistrer le repas.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProgrammePlanViewModel>().isSaving;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.repas.typeRepas,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Définissez les aliments, les quantités et les informations du repas.',
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _contenuController,
                minLines: 4,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Aliments et quantités',
                  hintText: 'Ex. 2 œufs, 60 g de pain complet, 1 pomme...',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.restaurant_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Renseignez le contenu du repas';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _selectionnerHeure,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Heure',
                    prefixIcon: Icon(Icons.schedule_outlined),
                  ),
                  child: Text(
                    _heure == null ? 'Non définie' : _heure!.format(context),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  suffixText: 'kcal',
                  prefixIcon: Icon(Icons.local_fire_department_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }

                  final calories = int.tryParse(value.trim());

                  if (calories == null || calories < 0) {
                    return 'Valeur incorrecte';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : _enregistrer,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    isSaving ? 'Enregistrement...' : 'Enregistrer le repas',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _ouvrirEditionJour(
  BuildContext context,
  int planId,
  PlanJour jour,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) {
      return _JourEditor(planId: planId, jour: jour);
    },
  );

  if (!context.mounted || result != true) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Informations du jour enregistrées.')),
  );
}

class _JourEditor extends StatefulWidget {
  const _JourEditor({required this.planId, required this.jour});

  final int planId;
  final PlanJour jour;

  @override
  State<_JourEditor> createState() => _JourEditorState();
}

class _JourEditorState extends State<_JourEditor> {
  late final TextEditingController _objectifController;

  late final TextEditingController _hydratationController;

  late final TextEditingController _activiteController;

  late final TextEditingController _recommandationsController;

  @override
  void initState() {
    super.initState();

    _objectifController = TextEditingController(
      text: widget.jour.objectifJournalier ?? '',
    );

    _hydratationController = TextEditingController(
      text: widget.jour.hydratation ?? '',
    );

    _activiteController = TextEditingController(
      text: widget.jour.activitePhysique ?? '',
    );

    _recommandationsController = TextEditingController(
      text: widget.jour.recommandations ?? '',
    );
  }

  @override
  void dispose() {
    _objectifController.dispose();
    _hydratationController.dispose();
    _activiteController.dispose();
    _recommandationsController.dispose();

    super.dispose();
  }

  Future<void> _enregistrer() async {
    final jourMisAJour = PlanJour(
      id: widget.jour.id,
      planId: widget.jour.planId,
      numeroJour: widget.jour.numeroJour,
      dateJour: widget.jour.dateJour,
      objectifJournalier: _nullableText(_objectifController.text),
      hydratation: _nullableText(_hydratationController.text),
      activitePhysique: _nullableText(_activiteController.text),
      recommandations: _nullableText(_recommandationsController.text),
      createdAt: widget.jour.createdAt,
      updatedAt: widget.jour.updatedAt,
      repas: widget.jour.repas,
    );

    final success = await context.read<ProgrammePlanViewModel>().updateJour(
      planId: widget.planId,
      jour: jourMisAJour,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<ProgrammePlanViewModel>().errorMessage ??
              'Impossible d’enregistrer les informations.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProgrammePlanViewModel>().isSaving;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jour ${widget.jour.numeroJour}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Complétez les recommandations quotidiennes du patient.',
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _objectifController,
              decoration: const InputDecoration(
                labelText: 'Objectif du jour',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _hydratationController,
              decoration: const InputDecoration(
                labelText: 'Hydratation',
                hintText: 'Ex. 2 litres d’eau',
                prefixIcon: Icon(Icons.water_drop_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _activiteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Activité physique',
                hintText: 'Ex. 30 minutes de marche',
                prefixIcon: Icon(Icons.directions_walk),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _recommandationsController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Recommandations',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.lightbulb_outline),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSaving ? null : _enregistrer,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(isSaving ? 'Enregistrement...' : 'Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErreurProgramme extends StatelessWidget {
  const _ErreurProgramme({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

bool _jourAInformations(PlanJour jour) {
  return _hasValue(jour.hydratation) ||
      _hasValue(jour.activitePhysique) ||
      _hasValue(jour.recommandations);
}

bool _hasValue(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String? _nullableText(String value) {
  final texte = value.trim();

  return texte.isEmpty ? null : texte;
}

IconData _mealIcon(String type) {
  switch (type.toLowerCase()) {
    case 'petit-déjeuner':
      return Icons.free_breakfast_outlined;

    case 'déjeuner':
      return Icons.lunch_dining_outlined;

    case 'collation':
      return Icons.fastfood_outlined;

    case 'dîner':
      return Icons.dinner_dining_outlined;

    default:
      return Icons.restaurant_outlined;
  }
}

String _formatDate(DateTime date) {
  final jour = date.day.toString().padLeft(2, '0');

  final mois = date.month.toString().padLeft(2, '0');

  return '$jour/$mois/${date.year}';
}

String _formatHeure(String heure) {
  final parts = heure.split(':');

  if (parts.length >= 2) {
    return '${parts[0]}:${parts[1]}';
  }

  return heure;
}

TimeOfDay? _parseHeure(String? heure) {
  if (heure == null) {
    return null;
  }

  final parts = heure.split(':');

  if (parts.length < 2) {
    return null;
  }

  final hour = int.tryParse(parts[0]);

  final minute = int.tryParse(parts[1]);

  if (hour == null || minute == null) {
    return null;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

String _apiHeure(TimeOfDay heure) {
  final hour = heure.hour.toString().padLeft(2, '0');

  final minute = heure.minute.toString().padLeft(2, '0');

  return '$hour:$minute:00';
}
