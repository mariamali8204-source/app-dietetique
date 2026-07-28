import 'package:flutter/material.dart';

import '../../models/patient.dart';

class PaysTelephone {
  final String nom;
  final String indicatif;
  final String exemple;

  const PaysTelephone({
    required this.nom,
    required this.indicatif,
    required this.exemple,
  });
}

class AjouterPatientView extends StatefulWidget {
  const AjouterPatientView({super.key});

  @override
  State<AjouterPatientView> createState() => _AjouterPatientViewState();
}

class _AjouterPatientViewState extends State<AjouterPatientView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  final List<PaysTelephone> _paysDisponibles = const [
    PaysTelephone(
      nom: 'Liban',
      indicatif: '+961',
      exemple: '71 123 456',
    ),
    PaysTelephone(
      nom: 'France',
      indicatif: '+33',
      exemple: '6 12 34 56 78',
    ),
    PaysTelephone(
      nom: 'Égypte',
      indicatif: '+20',
      exemple: '100 123 4567',
    ),
    PaysTelephone(
      nom: 'Jordanie',
      indicatif: '+962',
      exemple: '7 9012 3456',
    ),
    PaysTelephone(
      nom: 'Syrie',
      indicatif: '+963',
      exemple: '944 123 456',
    ),
    PaysTelephone(
      nom: 'Arabie saoudite',
      indicatif: '+966',
      exemple: '50 123 4567',
    ),
    PaysTelephone(
      nom: 'Émirats arabes unis',
      indicatif: '+971',
      exemple: '50 123 4567',
    ),
    PaysTelephone(
      nom: 'Qatar',
      indicatif: '+974',
      exemple: '3312 3456',
    ),
    PaysTelephone(
      nom: 'Koweït',
      indicatif: '+965',
      exemple: '500 12345',
    ),
    PaysTelephone(
      nom: 'Turquie',
      indicatif: '+90',
      exemple: '532 123 4567',
    ),
    PaysTelephone(
      nom: 'États-Unis',
      indicatif: '+1',
      exemple: '202 555 0100',
    ),
    PaysTelephone(
      nom: 'Canada',
      indicatif: '+1',
      exemple: '416 555 0100',
    ),
    PaysTelephone(
      nom: 'Royaume-Uni',
      indicatif: '+44',
      exemple: '7700 900123',
    ),
  ];

  final List<String> _objectifs = const [
    'Perte de poids',
    'Prise de poids',
    'Maintien du poids',
    'Nutrition équilibrée',
    'Diabète',
    'Cholestérol',
    'Plan sportif',
    'Grossesse',
    'Troubles digestifs',
    'Autre',
  ];

  final List<String> _statuts = const [
    'Actif',
    'Suivi',
    'En pause',
  ];

  late PaysTelephone _paysSelectionne;
  String _objectifSelectionne = 'Perte de poids';
  String _statutSelectionne = 'Actif';
  bool _notificationsAutorisees = true;

  @override
  void initState() {
    super.initState();
    _paysSelectionne = _paysDisponibles.first;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  void _enregistrerPatient() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final maintenant = DateTime.now();

    final nouveauPatient = Patient(
      id: 0,
      userId: 1,
      nom: _nomController.text.trim(),
      email: _emailController.text.trim(),
      pays: _paysSelectionne.nom,
      indicatif: _paysSelectionne.indicatif,
      telephone: _telephoneController.text.trim(),
      objectifNutritionnel: _objectifSelectionne,
      statut: _statutSelectionne,
      notificationsAutorisees: _notificationsAutorisees,
      createdAt: maintenant,
      updatedAt: maintenant,
    );

    Navigator.pop(context, nouveauPatient);
  }

  String? _validerNom(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }

    return null;
  }

  String? _validerEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L’adresse e-mail est obligatoire';
    }

    if (!value.contains('@') || !value.contains('.')) {
      return 'Adresse e-mail invalide';
    }

    return null;
  }

  String? _validerTelephone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le téléphone est obligatoire';
    }

    final telephoneNettoye = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (telephoneNettoye.length < 6) {
      return 'Numéro de téléphone invalide';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      appBar: AppBar(
        title: const Text('Ajouter un patient'),
        backgroundColor: const Color(0xFFF6FAF8),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: _validerNom,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse e-mail',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validerEmail,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<PaysTelephone>(
                    initialValue: _paysSelectionne,
                    decoration: const InputDecoration(
                      labelText: 'Pays',
                      prefixIcon: Icon(Icons.public),
                    ),
                    items: _paysDisponibles.map((pays) {
                      return DropdownMenuItem<PaysTelephone>(
                        value: pays,
                        child: Text('${pays.nom} (${pays.indicatif})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _paysSelectionne = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _telephoneController,
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone',
                      prefixIcon: const Icon(Icons.phone),
                      prefixText: '${_paysSelectionne.indicatif} ',
                      helperText: 'Exemple : ${_paysSelectionne.exemple}',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _validerTelephone,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _objectifSelectionne,
                    decoration: const InputDecoration(
                      labelText: 'Objectif nutritionnel',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: _objectifs.map((objectif) {
                      return DropdownMenuItem<String>(
                        value: objectif,
                        child: Text(objectif),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _objectifSelectionne = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _statutSelectionne,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      prefixIcon: Icon(Icons.check_circle),
                    ),
                    items: _statuts.map((statut) {
                      return DropdownMenuItem<String>(
                        value: statut,
                        child: Text(statut),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _statutSelectionne = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Notifications autorisées'),
                    value: _notificationsAutorisees,
                    onChanged: (value) {
                      setState(() {
                        _notificationsAutorisees = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _enregistrerPatient,
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}