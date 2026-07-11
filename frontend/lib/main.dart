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
      home: const DashboardView(),
    );
  }
}

class Patient {
  final String name;
  final String email;
  final String goal;
  final String status;

  const Patient({
    required this.name,
    required this.email,
    required this.goal,
    required this.status,
  });
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  final List<Patient> patients = const [
    Patient(
      name: 'Mariam Ali',
      email: 'mariam@example.com',
      goal: 'Perte de poids',
      status: 'Actif',
    ),
    Patient(
      name: 'Sally Ahmad',
      email: 'sally@example.com',
      goal: 'Plan sportif',
      status: 'Actif',
    ),
    Patient(
      name: 'Lina Khalil',
      email: 'lina@example.com',
      goal: 'Diabète',
      status: 'Suivi',
    ),
    Patient(
      name: 'Nour Hassan',
      email: 'nour@example.com',
      goal: 'Nutrition équilibrée',
      status: 'Actif',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
              'Dashboard diététique',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Suivi professionnel des patients et plans nutritionnels',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 22),

            Row(
              children: const [
                Expanded(
                  child: StatisticCard(
                    title: 'Patients',
                    value: '24',
                    icon: Icons.people_outline,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatisticCard(
                    title: 'Plans actifs',
                    value: '12',
                    icon: Icons.restaurant_menu_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: StatisticCard(
                    title: 'RDV aujourd’hui',
                    value: '5',
                    icon: Icons.calendar_month_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatisticCard(
                    title: 'Alertes',
                    value: '3',
                    icon: Icons.warning_amber_outlined,
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
                return PatientCard(patient: patient);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Formulaire d’ajout patient bientôt disponible'),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
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
                icon,
                color: const Color(0xFF0E7C66),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
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

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({
    super.key,
    required this.patient,
  });

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
          patient.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${patient.email}\nObjectif : ${patient.goal}',
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            patient.status,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}