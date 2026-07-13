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

class ResultatDossierPatient {
  final Patient? patientModifie;
  final bool patientSupprime;

  const ResultatDossierPatient({
    this.patientModifie,
    this.patientSupprime = false,
  });
}

class TableauDeBordView extends StatefulWidget {
  const TableauDeBordView({super.key});

  @override
  State<TableauDeBordView> createState() => _TableauDeBordViewState();
}

class _TableauDeBordViewState extends State<TableauDeBordView> {
  final TextEditingController rechercheController = TextEditingController();

  String texteRecherche = '';
  String filtreSelectionne = 'Tous';

  final List<String> filtresPatients = const [
    'Tous',
    'Actif',
    'Suivi',
    'En pause',
    'Notifications autorisées',
  ];

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

  List<Patient> get patientsFiltres {
    final String recherche = texteRecherche.toLowerCase().trim();

    return patients.where((patient) {
      final bool correspondRecherche =
          patient.nom.toLowerCase().contains(recherche) ||
          patient.email.toLowerCase().contains(recherche) ||
          patient.telephoneComplet.toLowerCase().contains(recherche) ||
          patient.objectif.toLowerCase().contains(recherche);

      final bool correspondFiltre;

      if (filtreSelectionne == 'Tous') {
        correspondFiltre = true;
      } else if (filtreSelectionne == 'Notifications autorisées') {
        correspondFiltre = patient.notificationsAutorisees;
      } else {
        correspondFiltre = patient.statut == filtreSelectionne;
      }

      return correspondRecherche && correspondFiltre;
    }).toList();
  }

  bool get rechercheOuFiltreActif {
    return texteRecherche.trim().isNotEmpty || filtreSelectionne != 'Tous';
  }

  void reinitialiserRechercheEtFiltre() {
    setState(() {
      rechercheController.clear();
      texteRecherche = '';
      filtreSelectionne = 'Tous';
    });
  }

  Future<void> ouvrirEcranAjoutPatient() async {
    final Patient? nouveauPatient = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(
        builder: (context) => const AjouterPatientView(),
      ),
    );

    if (nouveauPatient == null) {
      return;
    }

    setState(() {
      patients.add(nouveauPatient);
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient ajouté avec succès'),
      ),
    );
  }

  Future<void> ouvrirDossierPatient(int index) async {
    if (index < 0 || index >= patients.length) {
      return;
    }

    final Patient patient = patients[index];

    final ResultatDossierPatient? resultat =
        await Navigator.push<ResultatDossierPatient>(
      context,
      MaterialPageRoute(
        builder: (context) => DossierPatientView(
          patient: patient,
        ),
      ),
    );

    if (resultat == null || !mounted) {
      return;
    }

    if (resultat.patientSupprime) {
      setState(() {
        patients.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient supprimé avec succès'),
        ),
      );

      return;
    }

    if (resultat.patientModifie != null) {
      setState(() {
        patients[index] = resultat.patientModifie!;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Liste mise à jour avec succès'),
        ),
      );
    }
  }

  @override
  void dispose() {
    rechercheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int plansActifs = patients.length * 2;

    final int notificationsActives = patients
        .where(
          (patient) => patient.notificationsAutorisees,
        )
        .length;

    final List<Patient> listeAffichee = patientsFiltres;

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

            CarteRechercheEtFiltres(
              controller: rechercheController,
              texteRecherche: texteRecherche,
              filtreSelectionne: filtreSelectionne,
              filtres: filtresPatients,
              onRechercheChangee: (value) {
                setState(() {
                  texteRecherche = value;
                });
              },
              onFiltreChange: (value) {
                setState(() {
                  filtreSelectionne = value;
                });
              },
              onReinitialiser: reinitialiserRechercheEtFiltre,
            ),

            const SizedBox(height: 24),

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
                Text(
                  '${listeAffichee.length} résultat(s)',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (patients.isEmpty)
              const CarteListePatientsVide()
            else if (listeAffichee.isEmpty)
              CarteAucunResultat(
                rechercheOuFiltreActif: rechercheOuFiltreActif,
                onReinitialiser: reinitialiserRechercheEtFiltre,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listeAffichee.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 12);
                },
                itemBuilder: (context, index) {
                  final Patient patient = listeAffichee[index];
                  final int indexOriginal = patients.indexOf(patient);

                  return CartePatient(
                    patient: patient,
                    onTap: () {
                      ouvrirDossierPatient(indexOriginal);
                    },
                  );
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

class DossierPatientView extends StatefulWidget {
  final Patient patient;

  const DossierPatientView({
    super.key,
    required this.patient,
  });

  @override
  State<DossierPatientView> createState() => _DossierPatientViewState();
}

class _DossierPatientViewState extends State<DossierPatientView> {
  late Patient patientActuel;
  bool patientAEteModifie = false;

  @override
  void initState() {
    super.initState();
    patientActuel = widget.patient;
  }

  String texteNotification() {
    if (patientActuel.notificationsAutorisees) {
      return 'Oui, le patient accepte les rappels et les suivis.';
    }

    return 'Non, le patient ne souhaite pas recevoir de notifications.';
  }

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

  void retournerAuTableauDeBord() {
    Navigator.pop(
      context,
      ResultatDossierPatient(
        patientModifie: patientAEteModifie ? patientActuel : null,
      ),
    );
  }

  Future<void> ouvrirModificationPatient() async {
    final Patient? patientModifie = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(
        builder: (context) => AjouterPatientView(
          patientAModifier: patientActuel,
        ),
      ),
    );

    if (patientModifie == null || !mounted) {
      return;
    }

    setState(() {
      patientActuel = patientModifie;
      patientAEteModifie = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient modifié avec succès'),
      ),
    );
  }

  Future<void> demanderSuppression() async {
    final bool? confirmation = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            size: 40,
          ),
          title: const Text(
            'Confirmation de suppression',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Voulez-vous vraiment supprimer ce patient ?',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Garder le patient'),
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

    if (confirmation == true && mounted) {
      Navigator.pop(
        context,
        const ResultatDossierPatient(
          patientSupprime: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        retournerAuTableauDeBord();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: retournerAuTableauDeBord,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Dossier patient'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarteEntetePatient(
                patient: patientActuel,
              ),

              const SizedBox(height: 22),

              const Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              CarteInformation(
                icone: Icons.person_outline,
                titre: 'Nom complet',
                valeur: patientActuel.nom,
              ),

              CarteInformation(
                icone: Icons.email_outlined,
                titre: 'Adresse e-mail',
                valeur: patientActuel.email,
              ),

              CarteInformation(
                icone: Icons.phone_outlined,
                titre: 'Téléphone',
                valeur: patientActuel.telephoneComplet,
              ),

              CarteInformation(
                icone: Icons.public_outlined,
                titre: 'Pays',
                valeur: patientActuel.pays,
              ),

              const SizedBox(height: 22),

              const Text(
                'Suivi nutritionnel',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              CarteInformation(
                icone: Icons.flag_outlined,
                titre: 'Objectif nutritionnel',
                valeur: patientActuel.objectif,
              ),

              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Statut du patient'),
                  subtitle: Text(patientActuel.statut),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: couleurStatut(patientActuel.statut),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      patientActuel.statut,
                      style: TextStyle(
                        color: couleurTexteStatut(
                          patientActuel.statut,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              CarteInformation(
                icone: Icons.notifications_active_outlined,
                titre: 'Notifications autorisées',
                valeur: texteNotification(),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: ouvrirModificationPatient,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: demanderSuppression,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AjouterPatientView extends StatefulWidget {
  final Patient? patientAModifier;

  const AjouterPatientView({
    super.key,
    this.patientAModifier,
  });

  @override
  State<AjouterPatientView> createState() => _AjouterPatientViewState();
}

class _AjouterPatientViewState extends State<AjouterPatientView> {
  late final TextEditingController nomController;
  late final TextEditingController emailController;
  late final TextEditingController telephoneController;
  late final TextEditingController autreObjectifController;

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

  late PaysTelephone paysSelectionne;

  String objectifSelectionne = 'Perte de poids';
  String statutSelectionne = 'Actif';
  bool notificationsAutorisees = true;

  bool get estEnModeModification {
    return widget.patientAModifier != null;
  }

  @override
  void initState() {
    super.initState();

    final Patient? patient = widget.patientAModifier;

    nomController = TextEditingController(
      text: patient?.nom ?? '',
    );

    emailController = TextEditingController(
      text: patient?.email ?? '',
    );

    telephoneController = TextEditingController(
      text: patient?.telephone ?? '',
    );

    autreObjectifController = TextEditingController();

    if (patient == null) {
      paysSelectionne = paysDisponibles.first;
      return;
    }

    paysSelectionne = paysDisponibles.firstWhere(
      (pays) => pays.nom == patient.pays,
      orElse: () => paysDisponibles.first,
    );

    if (objectifsNutritionnels.contains(patient.objectif) &&
        patient.objectif != 'Autre') {
      objectifSelectionne = patient.objectif;
    } else {
      objectifSelectionne = 'Autre';
      autreObjectifController.text = patient.objectif;
    }

    if (statuts.contains(patient.statut)) {
      statutSelectionne = patient.statut;
    }

    notificationsAutorisees = patient.notificationsAutorisees;
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
          content: Text(
            'Veuillez saisir une adresse e-mail valide',
          ),
        ),
      );
      return;
    }

    final String telephoneSansEspaces = telephone.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (telephoneSansEspaces.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez saisir un numéro de téléphone valide',
          ),
        ),
      );
      return;
    }

    final Patient patientEnregistre = Patient(
      nom: nom,
      email: email,
      pays: paysSelectionne.nom,
      indicatif: paysSelectionne.indicatif,
      telephone: telephone,
      objectif: objectif,
      statut: statutSelectionne,
      notificationsAutorisees: notificationsAutorisees,
    );

    Navigator.pop(context, patientEnregistre);
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
        title: Text(
          estEnModeModification
              ? 'Modifier le patient'
              : 'Ajouter un patient',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              estEnModeModification
                  ? 'Modifier le dossier patient'
                  : 'Nouveau dossier patient',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              estEnModeModification
                  ? 'Mettez à jour les informations du patient.'
                  : 'Renseignez les informations principales du patient.',
              style: const TextStyle(
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
                return DropdownMenuItem<PaysTelephone>(
                  value: pays,
                  child: Text(
                    '${pays.nom} (${pays.indicatif})',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  if (paysSelectionne.nom != value.nom) {
                    telephoneController.clear();
                  }

                  paysSelectionne = value;
                });
              },
            ),

            const SizedBox(height: 16),

            ChampTexteProfessionnel(
              controller: telephoneController,
              label: 'Numéro de téléphone',
              icone: Icons.phone_outlined,
              typeClavier: TextInputType.phone,
              texteAide:
                  'Format attendu : ${paysSelectionne.indicatif} '
                  '${paysSelectionne.exemple}',
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
                  objectifSelectionne = value;

                  if (value != 'Autre') {
                    autreObjectifController.clear();
                  }
                });
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
                prefixIcon: const Icon(
                  Icons.check_circle_outline,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: statuts.map((statut) {
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
                  statutSelectionne = value;
                });
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
                label: Text(
                  estEnModeModification
                      ? 'Enregistrer les modifications'
                      : 'Enregistrer le patient',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
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

class CarteRechercheEtFiltres extends StatelessWidget {
  final TextEditingController controller;
  final String texteRecherche;
  final String filtreSelectionne;
  final List<String> filtres;
  final ValueChanged<String> onRechercheChangee;
  final ValueChanged<String> onFiltreChange;
  final VoidCallback onReinitialiser;

  const CarteRechercheEtFiltres({
    super.key,
    required this.controller,
    required this.texteRecherche,
    required this.filtreSelectionne,
    required this.filtres,
    required this.onRechercheChangee,
    required this.onFiltreChange,
    required this.onReinitialiser,
  });

  bool get rechercheOuFiltreActif {
    return texteRecherche.trim().isNotEmpty || filtreSelectionne != 'Tous';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onChanged: onRechercheChangee,
              decoration: InputDecoration(
                labelText: 'Rechercher un patient',
                hintText: 'Nom, e-mail, téléphone ou objectif',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: texteRecherche.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          controller.clear();
                          onRechercheChangee('');
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: const Color(0xFFF6F8FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filtres.map((filtre) {
                  final bool estSelectionne = filtre == filtreSelectionne;

                  return FilterChip(
                    label: Text(filtre),
                    selected: estSelectionne,
                    onSelected: (_) {
                      onFiltreChange(filtre);
                    },
                  );
                }).toList(),
              ),
            ),

            if (rechercheOuFiltreActif) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onReinitialiser,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réinitialiser'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CarteEntetePatient extends StatelessWidget {
  final Patient patient;

  const CarteEntetePatient({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF0E7C66),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person_outline,
                color: Color(0xFF0E7C66),
                size: 34,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    patient.objectif,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    patient.telephoneComplet,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
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

class CarteInformation extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String valeur;

  const CarteInformation({
    super.key,
    required this.icone,
    required this.titre,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icone),
        title: Text(titre),
        subtitle: Text(valeur),
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
        secondary: const Icon(
          Icons.notifications_active_outlined,
        ),
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
  final VoidCallback onTap;

  const CartePatient({
    super.key,
    required this.patient,
    required this.onTap,
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
    }

    return 'Notifications : Non';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
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
                    const SizedBox(height: 4),
                    const Text(
                      'Appuyer pour ouvrir le dossier',
                      style: TextStyle(
                        color: Color(0xFF0E7C66),
                        fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class CarteListePatientsVide extends StatelessWidget {
  const CarteListePatientsVide({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 28,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 46,
                color: Colors.black38,
              ),
              SizedBox(height: 12),
              Text(
                'Aucun patient enregistré',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Appuyez sur Ajouter pour créer un nouveau dossier patient.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarteAucunResultat extends StatelessWidget {
  final bool rechercheOuFiltreActif;
  final VoidCallback onReinitialiser;

  const CarteAucunResultat({
    super.key,
    required this.rechercheOuFiltreActif,
    required this.onReinitialiser,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 28,
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.search_off_outlined,
                size: 46,
                color: Colors.black38,
              ),
              const SizedBox(height: 12),
              const Text(
                'Aucun résultat trouvé',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Essayez une autre recherche ou modifiez le filtre sélectionné.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              if (rechercheOuFiltreActif) ...[
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: onReinitialiser,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réinitialiser'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}