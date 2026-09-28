import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;
  const MarkNotificationReadUseCase(this.repository);

  Future<void> call(String notificationId) =>
      repository.markAsRead(notificationId);
}
