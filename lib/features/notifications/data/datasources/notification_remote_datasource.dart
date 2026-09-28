import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> getMyNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  NotificationRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _ref => firestore.collection('notifications');

  @override
  Stream<List<NotificationModel>> getMyNotifications(String userId) {
    return _ref
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NotificationModel.fromJson(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _ref.doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw const ServerException('Failed to update notification.');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _ref
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw const ServerException('Failed to update notifications.');
    }
  }
}
