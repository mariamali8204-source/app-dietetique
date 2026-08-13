import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/navigation_view_model.dart';
import 'patient/patients_view.dart';

class MainShellView extends StatelessWidget {
  const MainShellView({super.key});

  static const List<Widget> _pages = [
    _PageTemporaire(
      icon: Icons.dashboard_outlined,
      title: 'Tableau de bord',
      description: 'Vue générale de l’activité nutritionnelle.',
    ),
    PatientsView(),
    _PageTemporaire(
      icon: Icons.restaurant_menu_outlined,
      title: 'Plans nutritionnels',
      description: 'Gestion des plans nutritionnels.',
    ),
    _PageTemporaire(
      icon: Icons.calendar_month_outlined,
      title: 'Rendez-vous',
      description: 'Gestion des rendez-vous.',
    ),
    _PageTemporaire(
      icon: Icons.notifications_outlined,
      title: 'Notifications',
      description: 'Consultation des notifications.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationViewModel>(
      builder: (context, navigationViewModel, child) {
        return Scaffold(
          body: IndexedStack(
            index: navigationViewModel.currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationViewModel.currentIndex,
            onDestinationSelected: navigationViewModel.updateIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Tableau',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Patients',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: 'Plans',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Rendez-vous',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PageTemporaire extends StatelessWidget {
  const _PageTemporaire({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
