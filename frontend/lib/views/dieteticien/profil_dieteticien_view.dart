import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ProfilDieteticienView extends StatefulWidget {
  const ProfilDieteticienView({super.key});

  @override
  State<ProfilDieteticienView> createState() => _ProfilDieteticienViewState();
}

class _ProfilDieteticienViewState extends State<ProfilDieteticienView> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specialiteController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _cliniqueController = TextEditingController();
  final TextEditingController _historiqueController = TextEditingController();

  String? _imagePath;
  String _pays = 'Lebanon';
  String _indicatif = '+961';
  String _telephone = '';

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _specialiteController.dispose();
    _experienceController.dispose();
    _cliniqueController.dispose();
    _historiqueController.dispose();
    super.dispose();
  }

  String _formatDialCode(String dialCode) {
    if (dialCode.startsWith('+')) {
      return dialCode;
    }
    return '+$dialCode';
  }

  Future<void> _choisirImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _imagePath = image.path;
    });
  }

  void _enregistrerProfil() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_telephone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un numéro de téléphone'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil enregistré localement'),
      ),
    );
  }

  String? _validerChampObligatoire(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
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

  Widget _photoProfil() {
    ImageProvider? imageProvider;

    if (_imagePath != null) {
      imageProvider = FileImage(File(_imagePath!));
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.teal.withValues(alpha: 0.15),
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? const Icon(
                  Icons.person,
                  size: 55,
                  color: Colors.teal,
                )
              : null,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _choisirImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Choisir une photo'),
        ),
      ],
    );
  }

  Widget _section({
    required String titre,
    required List<Widget> enfants,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...enfants,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      appBar: AppBar(
        title: const Text('Profil du diététicien'),
        backgroundColor: const Color(0xFFF6FAF8),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _section(
                titre: 'Photo de profil',
                enfants: [
                  Center(
                    child: _photoProfil(),
                  ),
                ],
              ),

              _section(
                titre: 'Informations personnelles',
                enfants: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: _validerChampObligatoire,
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
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    initialCountryCode: 'LB',
                    onChanged: (phone) {
                      setState(() {
                        _telephone = phone.number;
                        _indicatif = phone.countryCode;
                      });
                    },
                    onCountryChanged: (country) {
                      setState(() {
                        _pays = country.name;
                        _indicatif = _formatDialCode(country.dialCode);
                      });
                    },
                  ),
                ],
              ),

              _section(
                titre: 'Informations professionnelles',
                enfants: [
                  TextFormField(
                    controller: _specialiteController,
                    decoration: const InputDecoration(
                      labelText: 'Spécialité',
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    validator: _validerChampObligatoire,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _experienceController,
                    decoration: const InputDecoration(
                      labelText: 'Années d’expérience',
                      prefixIcon: Icon(Icons.work_history),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validerChampObligatoire,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cliniqueController,
                    decoration: const InputDecoration(
                      labelText: 'Clinique / Centre',
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    validator: _validerChampObligatoire,
                  ),
                ],
              ),

              _section(
                titre: 'Historique professionnel',
                enfants: [
                  TextFormField(
                    controller: _historiqueController,
                    decoration: const InputDecoration(
                      labelText: 'Résumé de l’expérience',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 5,
                    validator: _validerChampObligatoire,
                  ),
                ],
              ),

              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.public, color: Colors.teal),
                        title: const Text('Pays sélectionné'),
                        subtitle: Text(_pays),
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone, color: Colors.teal),
                        title: const Text('Téléphone complet'),
                        subtitle: Text('$_indicatif $_telephone'),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _enregistrerProfil,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer le profil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}