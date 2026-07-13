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
  final String pays;
  final String indicatif;
  final String telephone;
  final String objectif;
  final String statut;
  final bool notificationsAutorisees;

  const Patient({
    required this.nom,
    required this.email,
    required this.pays,
    required this.indicatif,
    required this.telephone,
    required this.objectif,
    required this.statut,
    required this.notificationsAutorisees,
  });

  String get telephoneComplet {
    return '$indicatif $telephone';
  }
}

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

class TableauDeBordView extends StatefulWidget {
  const TableauDeBordView({super.key});

  @override
  State<TableauDeBordView> createState() => _TableauDeBordViewState();
}

class _TableauDeBordViewState extends State<TableauDeBordView> {
  final List<Patient> patients = [
    const Patient(
      nom: 'Mariam Ali',
      email: 'mariam@example.com',
      pays: 'Liban',
      indicatif: '+961',
      telephone: '71 123 456',
      objectif: 'Perte de poids',
      statut: 'Actif',
      notificationsAutorisees: true,
    ),
    const Patient(
      nom: 'Sally Ahmad',
      email: 'sally@example.com',
      pays: 'France',
      indicatif: '+33',
      telephone: '6 12 34 56 78',
      objectif: 'Plan sportif',
      statut: 'Actif',
      notificationsAutorisees: true,
    ),
    const Patient(
      nom: 'Lina Khalil',
      email: 'lina@example.com',
      pays: 'Liban',
      indicatif: '+961',
      telephone: '76 987 654',
      objectif: 'Diabète',
      statut: 'Suivi',
      notificationsAutorisees: false,
    ),
    const Patient(
      nom: 'Nour Hassan',
      email: 'nour@example.com',
      pays: 'Jordanie',
      indicatif: '+962',
      telephone: '7 9012 3456',
      objectif: 'Nutrition équilibrée',
      statut: 'Actif',
      notificationsAutorisees: true,
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
    final int notificationsActives =
        patients.where((patient) => patient.notificationsAutorisees).length;

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

            Row(
              children: [
                const Expanded(
                  child: CarteStatistique(
                    titre: 'Rendez-vous',
                    valeur: '5',
                    icone: Icons.calendar_month_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CarteStatistique(
                    titre: 'Notifications',
                    valeur: notificationsActives.toString(),
                    icone: Icons.notifications_active_outlined,
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
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController autreObjectifController = TextEditingController();

  final List<PaysTelephone> paysDisponibles = const [
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
      exemple: '532 123 45 67',
    ),
    PaysTelephone(
      nom: 'États-Unis',
      indicatif: '+1',
      exemple: '202 555 0123',
    ),
    PaysTelephone(
      nom: 'Canada',
      indicatif: '+1',
      exemple: '416 555 0123',
    ),
    PaysTelephone(
      nom: 'Royaume-Uni',
      indicatif: '+44',
      exemple: '7400 123456',
    ),
  ];

  late PaysTelephone paysSelectionne;

  String objectifSelectionne = 'Perte de poids';
  String statutSelectionne = 'Actif';
  bool notificationsAutorisees = true;

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

  @override
  void initState() {
    super.initState();
    paysSelectionne = paysDisponibles.first;
  }

  void enregistrerPatient() {
    final String nom = nomController.text.trim();
    final String email = emailController.text.trim();
    final String telephone = telephoneController.text.trim();

    final String objectif = objectifSelectionne == 'Autre'
        ? autreObjectifController.text.trim()
        : objectifSelectionne;

    if (nom.isEmpty ||
        email.isEmpty ||
        telephone.isEmpty ||
        objectif.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une adresse e-mail valide'),
        ),
      );
      return;
    }

    final String telephoneSansEspaces =
        telephone.replaceAll(RegExp(r'[^0-9]'), '');

    if (telephoneSansEspaces.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un numéro de téléphone valide'),
        ),
      );
      return;
    }

    final Patient nouveauPatient = Patient(
      nom: nom,
      email: email,
      pays: paysSelectionne.nom,
      indicatif: paysSelectionne.indicatif,
      telephone: telephone,
      objectif: objectif,
      statut: statutSelectionne,
      notificationsAutorisees: notificationsAutorisees,
    );

    Navigator.pop(context, nouveauPatient);
  }

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
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

            DropdownButtonFormField<PaysTelephone>(
              value: paysSelectionne,
              decoration: InputDecoration(
                labelText: 'Pays',
                prefixIcon: const Icon(Icons.public_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: paysDisponibles.map((pays) {
                return DropdownMenuItem(
                  value: pays,
                  child: Text('${pays.nom} (${pays.indicatif})'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    paysSelectionne = value;
                    telephoneController.clear();
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            ChampTexteProfessionnel(
              controller: telephoneController,
              label: 'Numéro de téléphone',
              icone: Icons.phone_outlined,
              typeClavier: TextInputType.phone,
              texteAide:
                  'Format attendu : ${paysSelectionne.indicatif} ${paysSelectionne.exemple}',
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

            const SizedBox(height: 16),

            CarteNotification(
              notificationsAutorisees: notificationsAutorisees,
              onChanged: (value) {
                setState(() {
                  notificationsAutorisees = value;
                });
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
  final String? texteAide;

  const ChampTexteProfessionnel({
    super.key,
    required this.controller,
    required this.label,
    required this.icone,
    this.typeClavier = TextInputType.text,
    this.texteAide,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: typeClavier,
      decoration: InputDecoration(
        labelText: label,
        helperText: texteAide,
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

class CarteNotification extends StatelessWidget {
  final bool notificationsAutorisees;
  final ValueChanged<bool> onChanged;

  const CarteNotification({
    super.key,
    required this.notificationsAutorisees,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        value: notificationsAutorisees,
        onChanged: onChanged,
        secondary: const Icon(Icons.notifications_active_outlined),
        title: const Text(
          'Notifications autorisées',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          'Autoriser l’envoi de rappels et de suivis au patient',
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

  String texteNotification() {
    if (patient.notificationsAutorisees) {
      return 'Notifications : Oui';
    } else {
      return 'Notifications : Non';
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE0F2EE),
              child: Icon(
                Icons.person_outline,
                color: Color(0xFF0E7C66),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    patient.email,
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Téléphone : ${patient.telephoneComplet}',
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Pays : ${patient.pays}',
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Objectif : ${patient.objectif}',
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    texteNotification(),
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
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
          ],
        ),
      ),
    );
  }
}