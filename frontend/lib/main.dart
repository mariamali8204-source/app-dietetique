import 'package:flutter/material.dart';

import 'views/patient/patients_view.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const PatientsView(),
    );
  }
}