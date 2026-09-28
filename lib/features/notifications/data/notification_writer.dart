import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared helper for writing notification documents from any feature's
/// data source. Keeps the write co-located with the action that triggers it
/// (booking created/approved/rejected, complaint status changed) instead of
/// routing every caller through NotificationRepository.
class NotificationWriter {
  final FirebaseFirestore firestore;
  const NotificationWriter(this.firestore);

  Future<void> send({
    required String recipientId,
    required String type,
    required String title,
    required String body,
    String? actionRoute,
  }) async {
    try {
      await firestore.collection('notifications').add({
        'recipientId': recipientId,
        'type': type,
        'title': title,
        'body': body,
        'actionRoute': actionRoute,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Notification delivery is best-effort — never let it break the
      // primary action (booking/complaint write) that triggered it.
    }
  }
}
