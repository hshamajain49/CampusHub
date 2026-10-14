import 'package:campus_hub/features/auth/data/models/user_model.dart';
import 'package:campus_hub/features/auth/domain/entities/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeds Firestore documents shaped like the ones the app writes.
class Fixtures {
  final FirebaseFirestore db;
  Fixtures(this.db);

  static UserModel user(
    String uid, {
    UserRole role = UserRole.student,
    String? department,
    bool isActive = true,
  }) => UserModel(
    uid: uid,
    email: '$uid@campus.edu',
    name: 'User $uid',
    role: role,
    department: department,
    isActive: isActive,
    createdAt: DateTime(2026, 1, 1),
  );

  Future<UserModel> addUser(
    String uid, {
    UserRole role = UserRole.student,
    String? department,
    bool isActive = true,
  }) async {
    final model = user(
      uid,
      role: role,
      department: department,
      isActive: isActive,
    );
    await db.collection('users').doc(uid).set(model.toJson());
    return model;
  }

  Future<void> addVenue(String id, {required String coordinatorId}) {
    return db.collection('venues').doc(id).set({
      'name': 'Venue $id',
      'description': '',
      'capacity': 50,
      'building': 'Block A',
      'amenities': <String>[],
      'imageUrl': '',
      'isActive': true,
      'coordinatorId': coordinatorId,
    });
  }

  Future<void> addBooking(
    String id, {
    required String studentId,
    String venueId = 'hall',
    String coordinatorId = 'coord',
    String status = 'pending',
    DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now().add(const Duration(days: 7));
    return db.collection('bookings').doc(id).set({
      'venueId': venueId,
      'venueName': 'Venue $venueId',
      'studentId': studentId,
      'studentName': 'User $studentId',
      'coordinatorId': coordinatorId,
      'purpose': 'Meeting',
      'startDate': end.toIso8601String(),
      'endDate': end.toIso8601String(),
      'isFullDay': true,
      'startTime': null,
      'endTime': null,
      'status': status,
      'rejectionReason': null,
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
    });
  }

  Future<void> addComplaint(String id, {required String studentId}) {
    return db.collection('complaints').doc(id).set({
      'studentId': studentId,
      'studentName': 'User $studentId',
      'title': 'Broken projector',
      'description': null,
      'category': 'it',
      'assignedDepartment': 'IT Department',
      'location': null,
      'imageUrls': <String>[],
      'status': 'pending_review',
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
    });
  }

  Future<void> addNotification(String id, {required String recipientId}) {
    return db.collection('notifications').doc(id).set({
      'recipientId': recipientId,
      'type': 'general',
      'title': 'Hi',
      'body': 'There',
      'actionRoute': null,
      'isRead': false,
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
    });
  }

  Future<void> addSuggestion(
    String id, {
    required String authorId,
    List<String> upvotedBy = const [],
  }) {
    return db.collection('suggestions').doc(id).set({
      'authorId': authorId,
      'authorName': 'User $authorId',
      'title': 'Idea',
      'description': 'Details',
      'upvotedBy': upvotedBy,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
  }

  Future<Map<String, dynamic>?> data(String collection, String id) async {
    final doc = await db.collection(collection).doc(id).get();
    return doc.data();
  }
}
