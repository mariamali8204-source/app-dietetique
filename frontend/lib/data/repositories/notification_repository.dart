import '../../models/app_notification.dart';
import '../datasources/remote/notification_remote_data_source.dart';

class NotificationRepository {
  NotificationRepository({required this.remoteDataSource});

  final NotificationRemoteDataSource remoteDataSource;

  Future<List<AppNotification>> getNotifications() {
    return remoteDataSource.getNotifications();
  }

  Future<int> getNombreNonLues() {
    return remoteDataSource.getNombreNonLues();
  }

  Future<AppNotification> marquerCommeLue(int notificationId) {
    return remoteDataSource.marquerCommeLue(notificationId);
  }

  Future<void> marquerToutesCommeLues() {
    return remoteDataSource.marquerToutesCommeLues();
  }

  Future<void> deleteNotification(int notificationId) {
    return remoteDataSource.deleteNotification(notificationId);
  }
}
