import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../models/patient.dart';

class ModifierPatientView extends StatefulWidget {
  final Patient patient;

  const ModifierPatientView({super.key, required this.patient});

  @override
  State<ModifierPatientView> createState() {
    return _ModifierPatientViewState();
  }
}

class _ModifierPatientViewState extends State<ModifierPatientView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomController;
  late final TextEditingController _emailController;
  late final TextEditingController _autreObjectifController;

  final List<String> _objectifs = const [
    'Perte de poids',
    'Prise de poids',
    'Maintien du poids',
    'Nutrition équilibrée',
    'Diabète',
    'Cholestérol',
    'Hypertension',
    'Plan sportif',
    'Grossesse',
    'Troubles digestifs',
    'Rééquilibrage alimentaire',
    'Intolérances alimentaires',
    'Autre',
  ];

  final List<String> _statuts = const ['Actif', 'Suivi', 'En pause'];

  late String _paysSelectionne;
  late String _indicatifSelectionne;
  late String _telephoneSelectionne;

  late String _objectifSelectionne;
  late String _statutSelectionne;
  late bool _notificationsAutorisees;

  String? _initialCountryCode;

  bool get _objectifAutre {
    return _objectifSelectionne == 'Autre';
  }

  @override
  void initState() {
    super.initState();

    _nomController = TextEditingController(text: widget.patient.nom);

    _emailController = TextEditingController(text: widget.patient.email);

    _telephoneSelectionne = widget.patient.telephone;

    final country = _trouverPaysPatient();

    if (country != null) {
      _paysSelectionne = country.name;

      _indicatifSelectionne = '+${country.dialCode}';

      _initialCountryCode = country.code;
    } else {
      _paysSelectionne = widget.patient.pays;

      _indicatifSelectionne = widget.patient.indicatif;

      _initialCountryCode = null;
    }

    if (_objectifs.contains(widget.patient.objectifNutritionnel)) {
      _objectifSelectionne = widget.patient.objectifNutritionnel;

      _autreObjectifController = TextEditingController();
    } else {
      _objectifSelectionne = 'Autre';

      _autreObjectifController = TextEditingController(
        text: widget.patient.objectifNutritionnel,
      );
    }

    _statutSelectionne = widget.patient.statut;

    _notificationsAutorisees = widget.patient.notificationsAutorisees;
  }

  Country? _trouverPaysPatient() {
    final nomPatient = widget.patient.pays.trim().toLowerCase();

    final indicatifPatient = widget.patient.indicatif
        .replaceAll('+', '')
        .trim();

    // Chercher d'abord avec le nom du pays.
    for (final country in countries) {
      if (country.name.trim().toLowerCase() == nomPatient) {
        return country;
      }
    }

    // Si le nom ne correspond pas,
    // chercher avec l'indicatif téléphonique.
    for (final country in countries) {
      if (country.dialCode == indicatifPatient) {
        return country;
      }
    }

    return null;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _autreObjectifController.dispose();

    super.dispose();
  }

  String _formatDialCode(String dialCode) {
    if (dialCode.startsWith('+')) {
      return dialCode;
    }

    return '+$dialCode';
  }

  void _enregistrerModification() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_telephoneSelectionne.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un numéro de téléphone')),
      );

      return;
    }

    final objectifFinal = _objectifAutre
        ? _autreObjectifController.text.trim()
        : _objectifSelectionne;

    final patientModifie = Patient(
      id: widget.patient.id,
      userId: widget.patient.userId,
      nom: _nomController.text.trim(),
      email: _emailController.text.trim(),
      pays: _paysSelectionne,
      indicatif: _indicatifSelectionne,
      telephone: _telephoneSelectionne,
      objectifNutritionnel: objectifFinal,
      statut: _statutSelectionne,
      notificationsAutorisees: _notificationsAutorisees,
      createdAt: widget.patient.createdAt,
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(patientModifie);
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

  String? _validerAutreObjectif(String? value) {
    if (!_objectifAutre) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return 'Veuillez préciser l’objectif nutritionnel';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),

      appBar: AppBar(
        title: const Text('Modifier le patient'),
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

                  IntlPhoneField(
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      prefixIcon: Icon(Icons.phone),
                    ),

                    initialCountryCode: _initialCountryCode,

                    initialValue: widget.patient.telephone,

                    validator: (phone) {
                      if (phone == null || phone.number.trim().isEmpty) {
                        return 'Le téléphone est obligatoire';
                      }

                      return null;
                    },

                    onChanged: (phone) {
                      setState(() {
                        _telephoneSelectionne = phone.number;

                        _indicatifSelectionne = phone.countryCode;
                      });
                    },

                    onCountryChanged: (country) {
                      setState(() {
                        _paysSelectionne = country.name;

                        _indicatifSelectionne = _formatDialCode(
                          country.dialCode,
                        );
                      });
                    },
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
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _objectifSelectionne = value;

                        if (!_objectifAutre) {
                          _autreObjectifController.clear();
                        }
                      });
                    },
                  ),

                  if (_objectifAutre) ...[
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _autreObjectifController,
                      decoration: const InputDecoration(
                        labelText: 'Préciser l’objectif nutritionnel',
                        prefixIcon: Icon(Icons.edit_note),
                      ),
                      validator: _validerAutreObjectif,
                    ),
                  ],

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
                      if (value == null) {
                        return;
                      }

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
                      onPressed: _enregistrerModification,
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer les modifications'),
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
