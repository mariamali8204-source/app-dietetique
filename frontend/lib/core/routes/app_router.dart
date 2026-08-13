import 'package:flutter/material.dart';

import '../../models/patient.dart';
import '../../views/dieteticien/profil_dieteticien_view.dart';
import '../../views/main_shell_view.dart';
import '../../views/patient/ajouter_patient_view.dart';
import '../../views/patient/dossier_patient_view.dart';
import '../../views/patient/modifier_patient_view.dart';
import '../../views/patient/patients_view.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const MainShellView(),
          settings: settings,
        );

      case AppRoutes.patients:
        return MaterialPageRoute(
          builder: (_) => const PatientsView(),
          settings: settings,
        );

      case AppRoutes.addPatient:
        return MaterialPageRoute(
          builder: (_) => const AjouterPatientView(),
          settings: settings,
        );

      case AppRoutes.patientDetails:
        final argument = settings.arguments;

        if (argument is Patient) {
          return MaterialPageRoute(
            builder: (_) => DossierPatientView(patient: argument),
            settings: settings,
          );
        }

        return _errorRoute(message: 'Patient introuvable.', settings: settings);

      case AppRoutes.editPatient:
        final argument = settings.arguments;

        if (argument is Patient) {
          return MaterialPageRoute(
            builder: (_) => ModifierPatientView(patient: argument),
            settings: settings,
          );
        }

        return _errorRoute(message: 'Patient introuvable.', settings: settings);

      case AppRoutes.dietitianProfile:
        return MaterialPageRoute(
          builder: (_) => const ProfilDieteticienView(),
          settings: settings,
        );

      default:
        return _errorRoute(message: 'Page introuvable.', settings: settings);
    }
  }

  static Route<dynamic> _errorRoute({
    required String message,
    required RouteSettings settings,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
