import 'package:flutter/material.dart';

import '../../models/patient.dart';

class ModifierPatientView extends StatefulWidget {
  final Patient patient;

  const ModifierPatientView({
    super.key,
    required this.patient,
  });

  @override
  State<ModifierPatientView> createState() => _ModifierPatientViewState();
}

class _ModifierPatientViewState extends State<ModifierPatientView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomController;
  late final TextEditingController _emailController;
  late final TextEditingController _telephoneController;

  late String _objectif;
  late String _statut;
  late bool _notificationsAutorisees;

  @override
  void initState() {
    super.initState();

    _nomController = TextEditingController(text: widget.patient.nom);
    _emailController = TextEditingController(text: widget.patient.email);
    _telephoneController = TextEditingController(text: widget.patient.telephone);

    _objectif = widget.patient.objectifNutritionnel;
    _statut = widget.patient.statut;
    _notificationsAutorisees = widget.patient.notificationsAutorisees;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  void _modifierPatient() {
    if (_formKey.currentState!.validate()) {
      final patientModifie = Patient(
        id: widget.patient.id,
        userId: widget.patient.userId,
        nom: _nomController.text.trim(),
        email: _emailController.text.trim(),
        pays: widget.patient.pays,
        indicatif: widget.patient.indicatif,
        telephone: _telephoneController.text.trim(),
        objectifNutritionnel: _objectif,
        statut: _statut,
        notificationsAutorisees: _notificationsAutorisees,
        createdAt: widget.patient.createdAt,
        updatedAt: DateTime.now(),
      );

      Navigator.pop(context, patientModifie);
    }
  }

  List<DropdownMenuItem<String>> get _objectifs {
    return const [
      DropdownMenuItem(
        value: 'Perte de poids',
        child: Text('Perte de poids'),
      ),
      DropdownMenuItem(
        value: 'Prise de poids',
        child: Text('Prise de poids'),
      ),
      DropdownMenuItem(
        value: 'Maintien du poids',
        child: Text('Maintien du poids'),
      ),
      DropdownMenuItem(
        value: 'Nutrition équilibrée',
        child: Text('Nutrition équilibrée'),
      ),
      DropdownMenuItem(
        value: 'Diabète',
        child: Text('Diabète'),
      ),
      DropdownMenuItem(
        value: 'Cholestérol',
        child: Text('Cholestérol'),
      ),
      DropdownMenuItem(
        value: 'Plan sportif',
        child: Text('Plan sportif'),
      ),
    ];
  }

  List<DropdownMenuItem<String>> get _statuts {
    return const [
      DropdownMenuItem(
        value: 'Actif',
        child: Text('Actif'),
      ),
      DropdownMenuItem(
        value: 'Suivi',
        child: Text('Suivi'),
      ),
      DropdownMenuItem(
        value: 'En pause',
        child: Text('En pause'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le patient'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir le nom du patient';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Adresse e-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir l’adresse e-mail';
                  }
                  if (!value.contains('@')) {
                    return 'Veuillez saisir une adresse e-mail valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir le numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _objectif,
                decoration: const InputDecoration(
                  labelText: 'Objectif nutritionnel',
                  border: OutlineInputBorder(),
                ),
                items: _objectifs,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _objectif = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _statut,
                decoration: const InputDecoration(
                  labelText: 'Statut du patient',
                  border: OutlineInputBorder(),
                ),
                items: _statuts,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _statut = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text('Notifications autorisées'),
                value: _notificationsAutorisees,
                onChanged: (value) {
                  setState(() {
                    _notificationsAutorisees = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _modifierPatient,
                  child: const Text('Enregistrer les modifications'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}