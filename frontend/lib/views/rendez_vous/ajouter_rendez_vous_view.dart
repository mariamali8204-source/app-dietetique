import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/rendez_vous.dart';
import '../../viewmodels/patient_view_model.dart';
import '../../viewmodels/rendez_vous_view_model.dart';

class AjouterRendezVousView extends StatefulWidget {
  const AjouterRendezVousView({
    super.key,
    required this.dateInitiale,
    this.rendezVous,
  });

  final DateTime dateInitiale;
  final RendezVous? rendezVous;

  bool get estModification => rendezVous != null;

  @override
  State<AjouterRendezVousView> createState() {
    return _AjouterRendezVousViewState();
  }
}

class _AjouterRendezVousViewState extends State<AjouterRendezVousView> {
  final _formKey = GlobalKey<FormState>();

  final _motifController = TextEditingController();
  final _notesController = TextEditingController();

  int? _patientId;

  late DateTime _date;

  TimeOfDay _heureDebut = const TimeOfDay(hour: 9, minute: 0);

  TimeOfDay _heureFin = const TimeOfDay(hour: 9, minute: 45);

  String _typeRendezVous = 'En cabinet';
  String _statut = 'Planifié';

  bool _rappelPatientActive = true;

  @override
  void initState() {
    super.initState();

    final rendezVous = widget.rendezVous;

    if (rendezVous == null) {
      _date = widget.dateInitiale;
      return;
    }

    _patientId = rendezVous.patientId;
    _date = rendezVous.dateRendezVous;

    _heureDebut = _parseTime(rendezVous.heureDebut);

    _heureFin = _parseTime(rendezVous.heureFin);

    _motifController.text = rendezVous.motif;
    _notesController.text = rendezVous.notes ?? '';

    _typeRendezVous = rendezVous.typeRendezVous;
    _statut = rendezVous.statut;

    _rappelPatientActive = rendezVous.rappelPatientActive;
  }

  @override
  void dispose() {
    _motifController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      helpText: 'Sélectionner la date',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );

    if (date == null) {
      return;
    }

    setState(() {
      _date = date;
    });
  }

  Future<void> _choisirHeureDebut() async {
    final heure = await showTimePicker(
      context: context,
      initialTime: _heureDebut,
      helpText: 'Heure de début',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );

    if (heure == null) {
      return;
    }

    setState(() {
      _heureDebut = heure;

      final debutMinutes = heure.hour * 60 + heure.minute;

      final finMinutes = _heureFin.hour * 60 + _heureFin.minute;

      if (finMinutes <= debutMinutes) {
        final nouvelleFin = debutMinutes + 45;

        _heureFin = TimeOfDay(
          hour: (nouvelleFin ~/ 60) % 24,
          minute: nouvelleFin % 60,
        );
      }
    });
  }

  Future<void> _choisirHeureFin() async {
    final heure = await showTimePicker(
      context: context,
      initialTime: _heureFin,
      helpText: 'Heure de fin',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );

    if (heure == null) {
      return;
    }

    setState(() {
      _heureFin = heure;
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

    final debutMinutes = _heureDebut.hour * 60 + _heureDebut.minute;

    final finMinutes = _heureFin.hour * 60 + _heureFin.minute;

    if (finMinutes <= debutMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L’heure de fin doit être après l’heure de début.'),
        ),
      );

      return;
    }

    final ancienRendezVous = widget.rendezVous;
    final maintenant = DateTime.now();

    final rendezVous = RendezVous(
      id: ancienRendezVous?.id ?? 0,
      userId: ancienRendezVous?.userId ?? 0,
      patientId: _patientId!,
      dateRendezVous: _date,
      heureDebut: _formatTimeApi(_heureDebut),
      heureFin: _formatTimeApi(_heureFin),
      motif: _motifController.text.trim(),
      typeRendezVous: _typeRendezVous,
      statut: _statut,
      rappelPatientActive: _rappelPatientActive,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: ancienRendezVous?.createdAt ?? maintenant,
      updatedAt: maintenant,
    );

    final viewModel = context.read<RendezVousViewModel>();

    final success = widget.estModification
        ? await viewModel.updateRendezVous(rendezVous)
        : await viewModel.addRendezVous(rendezVous);

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
          viewModel.errorMessage ?? 'Impossible d’enregistrer le rendez-vous.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patients = context.watch<PatientViewModel>().patients;

    final rendezVousViewModel = context.watch<RendezVousViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.estModification
              ? 'Modifier le rendez-vous'
              : 'Nouveau rendez-vous',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Informations du rendez-vous',
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
                items: patients
                    .map(
                      (patient) => DropdownMenuItem<int>(
                        value: patient.id,
                        child: Text(patient.nom),
                      ),
                    )
                    .toList(),
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
                controller: _motifController,
                decoration: const InputDecoration(
                  labelText: 'Motif du rendez-vous',
                  prefixIcon: Icon(Icons.medical_information_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Saisissez un motif';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              Text(
                'Date et horaires',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date'),
                subtitle: Text(_formatDate(_date)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _choisirDate,
              ),

              Row(
                children: [
                  Expanded(
                    child: _TimeCard(
                      label: 'Début',
                      time: _heureDebut,
                      onTap: _choisirHeureDebut,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeCard(
                      label: 'Fin',
                      time: _heureFin,
                      onTap: _choisirHeureFin,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              DropdownButtonFormField<String>(
                initialValue: _typeRendezVous,
                decoration: const InputDecoration(
                  labelText: 'Type de rendez-vous',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'En cabinet',
                    child: Text('En cabinet'),
                  ),
                  DropdownMenuItem(value: 'En ligne', child: Text('En ligne')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _typeRendezVous = value;
                  });
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
                  DropdownMenuItem(value: 'Planifié', child: Text('Planifié')),
                  DropdownMenuItem(value: 'Confirmé', child: Text('Confirmé')),
                  DropdownMenuItem(value: 'Terminé', child: Text('Terminé')),
                  DropdownMenuItem(value: 'Annulé', child: Text('Annulé')),
                  DropdownMenuItem(value: 'Absent', child: Text('Absent')),
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

              const SizedBox(height: 18),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _rappelPatientActive,
                onChanged: (value) {
                  setState(() {
                    _rappelPatientActive = value;
                  });
                },
                title: const Text('Rappel patient'),
                subtitle: const Text('Préparer un rappel pour ce rendez-vous.'),
                secondary: const Icon(Icons.notifications_active_outlined),
              ),

              const SizedBox(height: 14),

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
                onPressed: rendezVousViewModel.isSubmitting
                    ? null
                    : _enregistrer,
                icon: rendezVousViewModel.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        widget.estModification
                            ? Icons.save_outlined
                            : Icons.event_available_outlined,
                      ),
                label: Text(
                  rendezVousViewModel.isSubmitting
                      ? 'Enregistrement...'
                      : widget.estModification
                      ? 'Enregistrer les modifications'
                      : 'Créer le rendez-vous',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static TimeOfDay _parseTime(String value) {
    final morceaux = value.split(':');

    return TimeOfDay(
      hour: int.parse(morceaux[0]),
      minute: int.parse(morceaux[1]),
    );
  }

  String _formatTimeApi(TimeOfDay time) {
    final heure = time.hour.toString().padLeft(2, '0');

    final minute = time.minute.toString().padLeft(2, '0');

    return '$heure:$minute:00';
  }

  String _formatDate(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');

    final mois = date.month.toString().padLeft(2, '0');

    return '$jour/$mois/${date.year}';
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    time.format(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
