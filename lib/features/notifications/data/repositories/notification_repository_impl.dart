import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  const NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<NotificationEntity>> getMyNotifications(String userId) =>
      remoteDataSource.getMyNotifications(userId);

  @override
  Future<void> markAsRead(String notificationId) =>
      remoteDataSource.markAsRead(notificationId);

  @override
  Future<void> markAllAsRead(String userId) =>
      remoteDataSource.markAllAsRead(userId);
}
