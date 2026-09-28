import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository repository;
  const MarkAllNotificationsReadUseCase(this.repository);

  Future<void> call(String userId) => repository.markAllAsRead(userId);
}
