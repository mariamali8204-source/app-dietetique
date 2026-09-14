import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/plan_nutritionnel.dart';
import '../../viewmodels/patient_view_model.dart';
import '../../viewmodels/plan_nutritionnel_view_model.dart';

class AjouterPlanNutritionnelView extends StatefulWidget {
  const AjouterPlanNutritionnelView({super.key, this.planAModifier});

  final PlanNutritionnel? planAModifier;

  bool get estModification => planAModifier != null;

  @override
  State<AjouterPlanNutritionnelView> createState() =>
      _AjouterPlanNutritionnelViewState();
}

class _AjouterPlanNutritionnelViewState
    extends State<AjouterPlanNutritionnelView> {
  final _formKey = GlobalKey<FormState>();

  final _titreController = TextEditingController();
  final _objectifController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();

  int? _patientId;
  String _statut = 'Actif';

  DateTime _dateDebut = DateTime.now();
  DateTime? _dateFin;

  bool get _estModification => widget.estModification;

  @override
  void initState() {
    super.initState();

    final plan = widget.planAModifier;

    if (plan == null) {
      return;
    }

    _patientId = plan.patientId;
    _titreController.text = plan.titre;
    _objectifController.text = plan.objectif;
    _caloriesController.text = plan.caloriesJournalieres?.toString() ?? '';
    _notesController.text = plan.notes ?? '';
    _statut = plan.statut;
    _dateDebut = plan.dateDebut;
    _dateFin = plan.dateFin;
  }

  @override
  void dispose() {
    _titreController.dispose();
    _objectifController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _choisirDateDebut() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Sélectionner la date de début',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );

    if (date == null) {
      return;
    }

    setState(() {
      _dateDebut = date;

      if (_dateFin != null && _dateFin!.isBefore(_dateDebut)) {
        _dateFin = null;
      }
    });
  }

  Future<void> _choisirDateFin() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateFin ?? _dateDebut,
      firstDate: _dateDebut,
      lastDate: DateTime(2035),
      helpText: 'Sélectionner la date de fin',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );

    if (date == null) {
      return;
    }

    setState(() {
      _dateFin = date;
    });
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un patient.')),
      );
      return;
    }

    final caloriesText = _caloriesController.text.trim();

    final calories = caloriesText.isEmpty ? null : int.tryParse(caloriesText);

    final maintenant = DateTime.now();
    final planExistant = widget.planAModifier;

    final plan = PlanNutritionnel(
      id: planExistant?.id ?? 0,
      userId: planExistant?.userId ?? 0,
      patientId: _patientId!,
      titre: _titreController.text.trim(),
      objectif: _objectifController.text.trim(),
      caloriesJournalieres: calories,
      dateDebut: _dateDebut,
      dateFin: _dateFin,
      statut: _statut,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: planExistant?.createdAt ?? maintenant,
      updatedAt: maintenant,
    );

    final viewModel = context.read<PlanNutritionnelViewModel>();

    final success = _estModification
        ? await viewModel.updatePlan(plan)
        : await viewModel.addPlan(plan);

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    final message = viewModel.errorMessage ?? 'Une erreur est survenue.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final patients = context.watch<PatientViewModel>().patients;

    final planViewModel = context.watch<PlanNutritionnelViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_estModification ? 'Modifier le plan' : 'Nouveau plan'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                _estModification
                    ? 'Modifier les informations du plan'
                    : 'Informations du plan',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<int>(
                initialValue: _patientId,
                decoration: const InputDecoration(
                  labelText: 'Patient',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: patients.map((patient) {
                  return DropdownMenuItem<int>(
                    value: patient.id,
                    child: Text(patient.nom),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _patientId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Sélectionnez un patient';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre du plan',
                  prefixIcon: Icon(Icons.restaurant_menu_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Saisissez un titre';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _objectifController,
                decoration: const InputDecoration(
                  labelText: 'Objectif nutritionnel',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Saisissez un objectif';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories journalières',
                  hintText: 'Ex. 1800',
                  suffixText: 'kcal',
                  prefixIcon: Icon(Icons.local_fire_department_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }

                  final calories = int.tryParse(value.trim());

                  if (calories == null || calories <= 0) {
                    return 'Saisissez une valeur valide';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _statut,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'Actif', child: Text('Actif')),
                  DropdownMenuItem(value: 'En pause', child: Text('En pause')),
                  DropdownMenuItem(value: 'Terminé', child: Text('Terminé')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _statut = value;
                  });
                },
              ),

              const SizedBox(height: 22),

              Text(
                'Période',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date de début'),
                subtitle: Text(_formatDate(_dateDebut)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _choisirDateDebut,
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('Date de fin'),
                subtitle: Text(
                  _dateFin == null ? 'Non définie' : _formatDate(_dateFin!),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _choisirDateFin,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),

              const SizedBox(height: 28),

              FilledButton.icon(
                onPressed: planViewModel.isSubmitting ? null : _enregistrer,
                icon: planViewModel.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _estModification
                            ? Icons.check_circle_outline
                            : Icons.save_outlined,
                      ),
                label: Text(
                  planViewModel.isSubmitting
                      ? 'Enregistrement...'
                      : _estModification
                      ? 'Enregistrer les modifications'
                      : 'Enregistrer le plan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
