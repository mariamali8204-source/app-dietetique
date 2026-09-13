import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/navigation_view_model.dart';
import 'dashboard/tableau_de_bord_view.dart';
import 'notification/notifications_view.dart';
import 'patient/patients_view.dart';
import 'plan/plans_nutritionnels_view.dart';
import 'rendez_vous/rendez_vous_view.dart';

class MainShellView extends StatelessWidget {
  const MainShellView({super.key});

  static const List<Widget> _pages = [
    TableauDeBordView(),
    PatientsView(),
    PlansNutritionnelsView(),
    RendezVousView(),
    NotificationsView(),
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
