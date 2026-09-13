import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';

import 'data/datasources/local/auth_local_data_source.dart';
import 'data/datasources/remote/auth_remote_data_source.dart';
import 'data/datasources/remote/health_remote_data_source.dart';
import 'data/datasources/remote/notification_remote_data_source.dart';
import 'data/datasources/remote/patient_remote_data_source.dart';
import 'data/datasources/remote/plan_nutritionnel_remote_data_source.dart';
import 'data/datasources/remote/programme_plan_remote_data_source.dart';
import 'data/datasources/remote/rendez_vous_remote_data_source.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/health_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/patient_repository.dart';
import 'data/repositories/plan_nutritionnel_repository.dart';
import 'data/repositories/programme_plan_repository.dart';
import 'data/repositories/rendez_vous_repository.dart';

import 'viewmodels/auth_view_model.dart';
import 'viewmodels/health_view_model.dart';
import 'viewmodels/navigation_view_model.dart';
import 'viewmodels/notification_view_model.dart';
import 'viewmodels/patient_view_model.dart';
import 'viewmodels/plan_nutritionnel_view_model.dart';
import 'viewmodels/programme_plan_view_model.dart';
import 'viewmodels/rendez_vous_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authLocalDataSource = AuthLocalDataSource();

  final authRepository = AuthRepository(
    remoteDataSource: AuthRemoteDataSource(),
    localDataSource: authLocalDataSource,
  );

  final patientRepository = PatientRepository(
    remoteDataSource: PatientRemoteDataSource(
      authLocalDataSource: authLocalDataSource,
    ),
  );

  final planRepository = PlanNutritionnelRepository(
    remoteDataSource: PlanNutritionnelRemoteDataSource(
      authLocalDataSource: authLocalDataSource,
    ),
  );

  final programmeRepository = ProgrammePlanRepository(
    remoteDataSource: ProgrammePlanRemoteDataSource(
      authLocalDataSource: authLocalDataSource,
    ),
  );

  final rendezVousRepository = RendezVousRepository(
    remoteDataSource: RendezVousRemoteDataSource(
      authLocalDataSource: authLocalDataSource,
    ),
  );

  final notificationRepository = NotificationRepository(
    remoteDataSource: NotificationRemoteDataSource(
      authLocalDataSource: authLocalDataSource,
    ),
  );

  final healthRepository = HealthRepository(
    remoteDataSource: HealthRemoteDataSource(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) =>
              AuthViewModel(repository: authRepository)..restoreSession(),
        ),
        ChangeNotifierProvider<NavigationViewModel>(
          create: (_) => NavigationViewModel(),
        ),
        ChangeNotifierProvider<PatientViewModel>(
          create: (context) {
            final authViewModel = context.read<AuthViewModel>();

            return PatientViewModel(
              repository: patientRepository,
              onUnauthorized: authViewModel.handleUnauthorized,
            );
          },
        ),
        ChangeNotifierProvider<PlanNutritionnelViewModel>(
          create: (context) {
            final authViewModel = context.read<AuthViewModel>();

            return PlanNutritionnelViewModel(
              repository: planRepository,
              onUnauthorized: authViewModel.handleUnauthorized,
            );
          },
        ),
        ChangeNotifierProvider<ProgrammePlanViewModel>(
          create: (context) {
            final authViewModel = context.read<AuthViewModel>();

            return ProgrammePlanViewModel(
              repository: programmeRepository,
              onUnauthorized: authViewModel.handleUnauthorized,
            );
          },
        ),
        ChangeNotifierProvider<RendezVousViewModel>(
          create: (context) {
            final authViewModel = context.read<AuthViewModel>();

            return RendezVousViewModel(
              repository: rendezVousRepository,
              onUnauthorized: authViewModel.handleUnauthorized,
            );
          },
        ),
        ChangeNotifierProvider<NotificationViewModel>(
          create: (context) {
            final authViewModel = context.read<AuthViewModel>();

            return NotificationViewModel(
              repository: notificationRepository,
              onUnauthorized: authViewModel.handleUnauthorized,
            );
          },
        ),
        ChangeNotifierProvider<HealthViewModel>(
          create: (_) =>
              HealthViewModel(repository: healthRepository)..checkBackend(),
        ),
      ],
      child: const NutriCareProApp(),
    ),
  );
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF6FAF8),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.18)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(width: 1.5, color: Colors.teal),
          ),
        ),
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
