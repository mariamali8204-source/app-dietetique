import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_notification.dart';
import '../../viewmodels/notification_view_model.dart';
import '../../viewmodels/patient_view_model.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() {
    return _NotificationsViewState();
  }
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _nonLuesSeulement = false;
  bool _loaded = false;

  final TextEditingController _rechercheController = TextEditingController();

  String _recherche = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) {
      return;
    }

    _loaded = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  // =========================================================
  // RECHERCHE
  // =========================================================

  List<AppNotification> _filtrerNotifications(
    List<AppNotification> notifications,
    PatientViewModel patientViewModel,
  ) {
    final recherche = _recherche.trim().toLowerCase();

    return notifications.where((notification) {
      if (_nonLuesSeulement && notification.estLue) {
        return false;
      }

      if (recherche.isEmpty) {
        return true;
      }

      final patientNom = _nomPatient(
        patientViewModel,
        notification.patientId,
      ).toLowerCase();

      return patientNom.contains(recherche);
    }).toList();
  }

  void _viderRecherche() {
    _rechercheController.clear();

    setState(() {
      _recherche = '';
    });
  }

  Widget _barreRecherche() {
    return TextField(
      controller: _rechercheController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Rechercher par patient...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _recherche.isEmpty
            ? null
            : IconButton(
                onPressed: _viderRecherche,
                icon: const Icon(Icons.close),
                tooltip: 'Effacer la recherche',
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        setState(() {
          _recherche = value;
        });
      },
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotificationViewModel, PatientViewModel>(
      builder: (context, notificationViewModel, patientViewModel, child) {
        final notifications = _filtrerNotifications(
          notificationViewModel.notifications,
          patientViewModel,
        );

        return SafeArea(
          child: Scaffold(
            body: RefreshIndicator(
              onRefresh: notificationViewModel.loadNotifications,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notificationViewModel.nombreNonLues == 0
                                  ? 'Aucune notification non lue'
                                  : '${notificationViewModel.nombreNonLues} notification(s) non lue(s)',
                            ),
                          ],
                        ),
                      ),
                      if (notificationViewModel.nombreNonLues > 0)
                        TextButton(
                          onPressed: notificationViewModel.isSubmitting
                              ? null
                              : () {
                                  notificationViewModel
                                      .marquerToutesCommeLues();
                                },
                          child: const Text('Tout lire'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _barreRecherche(),

                  const SizedBox(height: 16),

                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Toutes'),
                        icon: Icon(Icons.notifications_outlined),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Non lues'),
                        icon: Icon(Icons.mark_email_unread_outlined),
                      ),
                    ],
                    selected: {_nonLuesSeulement},
                    onSelectionChanged: (value) {
                      setState(() {
                        _nonLuesSeulement = value.first;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  if (notificationViewModel.isLoading &&
                      notificationViewModel.notifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 70),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (notificationViewModel.errorMessage != null &&
                      notificationViewModel.notifications.isEmpty)
                    _EtatErreur(
                      message: notificationViewModel.errorMessage!,
                      onRetry: notificationViewModel.loadNotifications,
                    )
                  else if (notificationViewModel.notifications.isEmpty)
                    const _EtatVide()
                  else if (notifications.isEmpty)
                    _AucunResultatRecherche(
                      rechercheActive: _recherche.trim().isNotEmpty,
                      nonLuesSeulement: _nonLuesSeulement,
                      onEffacer: _viderRecherche,
                    )
                  else
                    ...notifications.map((notification) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NotificationCard(
                          notification: notification,
                          patientNom: _nomPatient(
                            patientViewModel,
                            notification.patientId,
                          ),
                          onLire: () {
                            if (!notification.estLue) {
                              notificationViewModel.marquerCommeLue(
                                notification.id,
                              );
                            }
                          },
                          onSupprimer: () {
                            _confirmerSuppression(notification);
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // NOM PATIENT
  // =========================================================

  String _nomPatient(PatientViewModel viewModel, int patientId) {
    for (final patient in viewModel.patients) {
      if (patient.id == patientId) {
        return patient.nom;
      }
    }

    return 'Patient';
  }

  // =========================================================
  // SUPPRESSION
  // =========================================================

  Future<void> _confirmerSuppression(AppNotification notification) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la notification'),
          content: const Text(
            'Voulez-vous vraiment supprimer cette notification ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmer != true || !mounted) {
      return;
    }

    await context.read<NotificationViewModel>().deleteNotification(
      notification.id,
    );
  }
}

// =========================================================
// CARTE NOTIFICATION
// =========================================================

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.patientNom,
    required this.onLire,
    required this.onSupprimer,
  });

  final AppNotification notification;
  final String patientNom;

  final VoidCallback onLire;
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    final couleur = _couleurStatut(notification.statut);

    return InkWell(
      onTap: onLire,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.estLue
              ? Colors.white
              : Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notification.estLue
                ? Colors.grey.withValues(alpha: 0.12)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconeCanal(notification.canal), color: couleur),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.titre,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: notification.estLue
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                              ),
                        ),
                      ),
                      if (!notification.estLue)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    patientNom,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(notification.message),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(
                        icon: _iconeCanal(notification.canal),
                        label: notification.canal,
                      ),
                      _Chip(
                        icon: Icons.schedule_outlined,
                        label: notification.statut,
                        color: couleur,
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      Text(
                        _formatDate(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        tooltip: 'Actions',
                        onSelected: (value) {
                          if (value == 'lire') {
                            onLire();
                          }

                          if (value == 'supprimer') {
                            onSupprimer();
                          }
                        },
                        itemBuilder: (_) {
                          return [
                            if (!notification.estLue)
                              const PopupMenuItem(
                                value: 'lire',
                                child: Text('Marquer comme lue'),
                              ),
                            const PopupMenuItem(
                              value: 'supprimer',
                              child: Text('Supprimer'),
                            ),
                          ];
                        },
                      ),
                    ],
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

// =========================================================
// CHIP
// =========================================================

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final couleur = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: couleur),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// AUCUN RESULTAT
// =========================================================

class _AucunResultatRecherche extends StatelessWidget {
  const _AucunResultatRecherche({
    required this.rechercheActive,
    required this.nonLuesSeulement,
    required this.onEffacer,
  });

  final bool rechercheActive;
  final bool nonLuesSeulement;
  final VoidCallback onEffacer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 55),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 56, color: Colors.grey),

          const SizedBox(height: 14),

          Text(
            rechercheActive
                ? 'Aucune notification trouvée'
                : 'Aucune notification non lue',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 7),

          Text(
            rechercheActive
                ? 'Aucune notification ne correspond à ce patient.'
                : nonLuesSeulement
                ? 'Toutes vos notifications ont été lues.'
                : 'Aucune notification disponible.',
            textAlign: TextAlign.center,
          ),

          if (rechercheActive) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onEffacer,
              icon: const Icon(Icons.close),
              label: const Text('Effacer la recherche'),
            ),
          ],
        ],
      ),
    );
  }
}

// =========================================================
// ETAT VIDE
// =========================================================

class _EtatVide extends StatelessWidget {
  const _EtatVide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 42),
          ),
          const SizedBox(height: 18),
          Text(
            'Aucune notification',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 7),
          const Text(
            'Les rappels et informations apparaîtront ici.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =========================================================
// ERREUR
// =========================================================

class _EtatErreur extends StatelessWidget {
  const _EtatErreur({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 50),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// HELPERS
// =========================================================

IconData _iconeCanal(String canal) {
  switch (canal) {
    case 'Email':
      return Icons.email_outlined;

    case 'WhatsApp':
      return Icons.chat_outlined;

    case 'Application':
    default:
      return Icons.notifications_outlined;
  }
}

Color _couleurStatut(String statut) {
  switch (statut) {
    case 'Envoyé':
      return Colors.green;

    case 'Échoué':
      return Colors.red;

    case 'Programmé':
    default:
      return Colors.orange;
  }
}

String _formatDate(DateTime date) {
  final jour = date.day.toString().padLeft(2, '0');

  final mois = date.month.toString().padLeft(2, '0');

  final heure = date.hour.toString().padLeft(2, '0');

  final minute = date.minute.toString().padLeft(2, '0');

  return '$jour/$mois/${date.year} · $heure:$minute';
}
