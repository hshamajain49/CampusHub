import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String recipientId;
  final String
  type; // 'new_booking_request' | 'booking_approved' | 'booking_rejected' | 'complaint_status'
  final String title;
  final String body;
  final String? actionRoute;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    this.actionRoute,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    recipientId,
    type,
    title,
    body,
    actionRoute,
    isRead,
    createdAt,
  ];
}
