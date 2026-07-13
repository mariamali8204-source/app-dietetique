import 'package:flutter/material.dart';

void main() {
  runApp(const NutriCareProApp());
}

class NutriCareProApp extends StatelessWidget {
  const NutriCareProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriCare Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E7C66),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
      ),
      home: const TableauDeBordView(),
    );
  }
}

class Patient {
  final String nom;
  final String email;
  final String objectif;
  final String statut;

  const Patient({
    required this.nom,
    required this.email,
    required this.objectif,
    required this.statut,
  });
}

class TableauDeBordView extends StatefulWidget {
  const TableauDeBordView({super.key});

  @override
  State<TableauDeBordView> createState() => _TableauDeBordViewState();
}

class _TableauDeBordViewState extends State<TableauDeBordView> {
  final List<Patient> patients = [
    const Patient(
      nom: 'Mariam Ali',
      email: 'mariam.ali8204@gmail.com',
      objectif: 'Perte de poids',
      statut: 'Actif',
    ),
    const Patient(
      nom: 'Sally Homsi',
      email: 'sallyhomsi17@gmail.com',
      objectif: 'Plan sportif',
      statut: 'Actif',
    ),
    const Patient(
      nom: 'Lina Khalil',
      email: 'lina655@icloud.com',
      objectif: 'Diabète',
      statut: 'Suivi',
    ),
    const Patient(
      nom: 'Nour Hassan',
      email: 'nour.hassan4@gmail.com',
      objectif: 'Nutrition équilibrée',
      statut: 'Actif',
    ),
  ];

  Future<void> ouvrirEcranAjoutPatient() async {
    final Patient? nouveauPatient = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AjouterPatientView(),
      ),
    );

    if (nouveauPatient != null) {
      setState(() {
        patients.add(nouveauPatient);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient ajouté avec succès'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int plansActifs = patients.length * 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriCare Pro'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tableau de bord diététique',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Suivi professionnel des patients et des plans nutritionnels',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: CarteStatistique(
                    titre: 'Patients',
                    valeur: patients.length.toString(),
                    icone: Icons.people_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CarteStatistique(
                    titre: 'Plans actifs',
                    valeur: plansActifs.toString(),
                    icone: Icons.restaurant_menu_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Row(
              children: [
                Expanded(
                  child: CarteStatistique(
                    titre: 'Rendez-vous',
                    valeur: '5',
                    icone: Icons.calendar_month_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CarteStatistique(
                    titre: 'Alertes',
                    valeur: '3',
                    icone: Icons.warning_amber_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Patients récents',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Voir tout'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: patients.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final patient = patients[index];
                return CartePatient(patient: patient);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ouvrirEcranAjoutPatient,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}

class AjouterPatientView extends StatefulWidget {
  const AjouterPatientView({super.key});

  @override
  State<AjouterPatientView> createState() => _AjouterPatientViewState();
}

class _AjouterPatientViewState extends State<AjouterPatientView> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController autreObjectifController = TextEditingController();

  String objectifSelectionne = 'Perte de poids';
  String statutSelectionne = 'Actif';

  final List<String> objectifsNutritionnels = const [
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

  final List<String> statuts = const [
    'Actif',
    'Suivi',
    'En pause',
  ];

  void enregistrerPatient() {
    final String nom = nomController.text.trim();
    final String email = emailController.text.trim();

    final String objectif = objectifSelectionne == 'Autre'
        ? autreObjectifController.text.trim()
        : objectifSelectionne;

    if (nom.isEmpty || email.isEmpty || objectif.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une adresse e-mail valide'),
        ),
      );
      return;
    }

    final Patient nouveauPatient = Patient(
      nom: nom,
      email: email,
      objectif: objectif,
      statut: statutSelectionne,
    );

    Navigator.pop(context, nouveauPatient);
  }

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    autreObjectifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool afficherAutreObjectif = objectifSelectionne == 'Autre';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un patient'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nouveau dossier patient',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Renseignez les informations principales du patient.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 24),

            ChampTexteProfessionnel(
              controller: nomController,
              label: 'Nom complet',
              icone: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            ChampTexteProfessionnel(
              controller: emailController,
              label: 'Adresse e-mail',
              icone: Icons.email_outlined,
              typeClavier: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: objectifSelectionne,
              decoration: InputDecoration(
                labelText: 'Objectif nutritionnel',
                prefixIcon: const Icon(Icons.flag_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: objectifsNutritionnels.map((objectif) {
                return DropdownMenuItem(
                  value: objectif,
                  child: Text(objectif),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    objectifSelectionne = value;
                  });
                }
              },
            ),

            if (afficherAutreObjectif) ...[
              const SizedBox(height: 16),
              ChampTexteProfessionnel(
                controller: autreObjectifController,
                label: 'Préciser l’objectif',
                icone: Icons.edit_outlined,
              ),
            ],

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: statutSelectionne,
              decoration: InputDecoration(
                labelText: 'Statut du patient',
                prefixIcon: const Icon(Icons.check_circle_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: statuts.map((statut) {
                return DropdownMenuItem(
                  value: statut,
                  child: Text(statut),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    statutSelectionne = value;
                  });
                }
              },
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: enregistrerPatient,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Enregistrer le patient'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChampTexteProfessionnel extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icone;
  final TextInputType typeClavier;

  const ChampTexteProfessionnel({
    super.key,
    required this.controller,
    required this.label,
    required this.icone,
    this.typeClavier = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: typeClavier,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class CarteStatistique extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icone;

  const CarteStatistique({
    super.key,
    required this.titre,
    required this.valeur,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE0F2EE),
              child: Icon(
                icone,
                color: const Color(0xFF0E7C66),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              valeur,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titre,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartePatient extends StatelessWidget {
  final Patient patient;

  const CartePatient({
    super.key,
    required this.patient,
  });

  Color couleurStatut(String statut) {
    if (statut == 'Actif') {
      return const Color(0xFFE8F5E9);
    } else if (statut == 'Suivi') {
      return const Color(0xFFE3F2FD);
    } else {
      return const Color(0xFFFFF3E0);
    }
  }

  Color couleurTexteStatut(String statut) {
    if (statut == 'Actif') {
      return const Color(0xFF2E7D32);
    } else if (statut == 'Suivi') {
      return const Color(0xFF1565C0);
    } else {
      return const Color(0xFFE65100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0F2EE),
          child: Icon(
            Icons.person_outline,
            color: Color(0xFF0E7C66),
          ),
        ),
        title: Text(
          patient.nom,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${patient.email}\nObjectif : ${patient.objectif}',
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: couleurStatut(patient.statut),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            patient.statut,
            style: TextStyle(
              color: couleurTexteStatut(patient.statut),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}