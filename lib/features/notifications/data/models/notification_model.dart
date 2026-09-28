import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    required super.type,
    required super.title,
    required super.body,
    super.actionRoute,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(String id, Map<String, dynamic> json) {
    return NotificationModel(
      id: id,
      recipientId: json['recipientId'] as String,
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String,
      body: json['body'] as String,
      actionRoute: json['actionRoute'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
