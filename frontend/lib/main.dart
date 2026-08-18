import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';

import 'data/datasources/local/auth_local_data_source.dart';
import 'data/datasources/remote/auth_remote_data_source.dart';
import 'data/datasources/remote/health_remote_data_source.dart';
import 'data/datasources/remote/patient_remote_data_source.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/health_repository.dart';
import 'data/repositories/patient_repository.dart';

import 'viewmodels/auth_view_model.dart';
import 'viewmodels/health_view_model.dart';
import 'viewmodels/navigation_view_model.dart';
import 'viewmodels/patient_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authRemoteDataSource = AuthRemoteDataSource();

  final authLocalDataSource = AuthLocalDataSource();

  final authRepository = AuthRepository(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );

  final patientRemoteDataSource = PatientRemoteDataSource(
    authLocalDataSource: authLocalDataSource,
  );

  final patientRepository = PatientRepository(
    remoteDataSource: patientRemoteDataSource,
  );

  final healthRemoteDataSource = HealthRemoteDataSource();

  final healthRepository = HealthRepository(
    remoteDataSource: healthRemoteDataSource,
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
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
