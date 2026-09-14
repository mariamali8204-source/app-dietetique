import 'package:flutter/foundation.dart';

import '../data/datasources/remote/notification_remote_data_source.dart';
import '../data/repositories/notification_repository.dart';
import '../models/app_notification.dart';

typedef NotificationUnauthorizedHandler = Future<void> Function();

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel({
    required this.repository,
    required this.onUnauthorized,
  });

  final NotificationRepository repository;
  final NotificationUnauthorizedHandler onUnauthorized;

  final List<AppNotification> _notifications = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<AppNotification> get notifications {
    return List.unmodifiable(_notifications);
  }

  bool get isLoading => _isLoading;

  bool get isSubmitting => _isSubmitting;

  String? get errorMessage => _errorMessage;

  int get nombreNonLues {
    return _notifications.where((notification) => !notification.estLue).length;
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.getNotifications();

      _notifications
        ..clear()
        ..addAll(result);

      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on NotificationUnauthorizedException {
      await onUnauthorized();
    } catch (_) {
      _errorMessage = 'Impossible de charger les notifications.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> marquerCommeLue(int notificationId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await repository.marquerCommeLue(notificationId);

      final index = _notifications.indexWhere(
        (notification) => notification.id == notificationId,
      );

      if (index != -1) {
        _notifications[index] = updated;
      }

      return true;
    } on NotificationUnauthorizedException {
      await onUnauthorized();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible de mettre à jour la notification.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> marquerToutesCommeLues() async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.marquerToutesCommeLues();

      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(estLue: true);
      }

      return true;
    } on NotificationUnauthorizedException {
      await onUnauthorized();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible de mettre à jour les notifications.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteNotification(notificationId);

      _notifications.removeWhere(
        (notification) => notification.id == notificationId,
      );

      return true;
    } on NotificationUnauthorizedException {
      await onUnauthorized();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible de supprimer la notification.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _errorMessage = null;
    _isLoading = false;
    _isSubmitting = false;

    notifyListeners();
  }
}
