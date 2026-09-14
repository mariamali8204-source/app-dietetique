import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/patient_view_model.dart';
import '../../viewmodels/plan_nutritionnel_view_model.dart';
import '../../viewmodels/programme_plan_view_model.dart';
import '../../viewmodels/rendez_vous_view_model.dart';
import '../main_shell_view.dart';
import 'login_view.dart';

class AuthGateView extends StatefulWidget {
  const AuthGateView({super.key});

  @override
  State<AuthGateView> createState() {
    return _AuthGateViewState();
  }
}

class _AuthGateViewState extends State<AuthGateView> {
  int? _loadedUserId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (!authViewModel.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = authViewModel.currentUser;

        if (currentUser == null) {
          if (_loadedUserId != null) {
            _loadedUserId = null;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }

              context.read<PatientViewModel>().clearPatients();

              context.read<PlanNutritionnelViewModel>().clearPlans();

              context.read<ProgrammePlanViewModel>().clearProgramme();

              context.read<RendezVousViewModel>().clearRendezVous();
            });
          }

          return const LoginView();
        }

        if (_loadedUserId != currentUser.id) {
          _loadedUserId = currentUser.id;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }

            context.read<ProgrammePlanViewModel>().clearProgramme();

            context.read<PatientViewModel>().loadPatients();

            context.read<PlanNutritionnelViewModel>().loadPlans();

            context.read<RendezVousViewModel>().loadRendezVous();
          });
        }

        return const MainShellView();
      },
    );
  }
}
