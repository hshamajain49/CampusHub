import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetMyNotificationsUseCase {
  final NotificationRepository repository;
  const GetMyNotificationsUseCase(this.repository);

  Stream<List<NotificationEntity>> call(String userId) =>
      repository.getMyNotifications(userId);
}
