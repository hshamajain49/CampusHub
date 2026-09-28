import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../notifications/data/notification_writer.dart';
import '../../domain/entities/complaint_category.dart';
import '../../domain/entities/complaint_status.dart';
import '../models/complaint_model.dart';

abstract class ComplaintRemoteDataSource {
  Future<ComplaintModel> createComplaint({
    required String title,
    String? description,
    required ComplaintCategory category,
    String? location,
    required List<String> imagePaths,
  });

  Stream<List<ComplaintModel>> getMyComplaints(String studentId);

  Future<ComplaintModel> getComplaintById(String id);

  Future<ComplaintModel> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus status,
  });

  Stream<List<ComplaintModel>> getComplaintsByDepartment(String department);
}

class ComplaintRemoteDataSourceImpl implements ComplaintRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final CloudinaryService cloudinaryService;
  final NotificationWriter notificationWriter;

  ComplaintRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.cloudinaryService,
    required this.notificationWriter,
  });

  CollectionReference get _complaintsRef => firestore.collection('complaints');

  @override
  Future<ComplaintModel> createComplaint({
    required String title,
    String? description,
    required ComplaintCategory category,
    String? location,
    required List<String> imagePaths,
  }) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const AuthException(
          'You must be logged in to submit a complaint.',
        );
      }

      final userDoc = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final studentName = (userDoc.data()?['name'] as String?) ?? 'Unknown';

      List<String> imageUrls = [];
      if (imagePaths.isNotEmpty) {
        final files = imagePaths.map((path) => File(path)).toList();
        imageUrls = await cloudinaryService.uploadImages(files);
      }

      final now = DateTime.now();
      final docRef = _complaintsRef.doc();

      final complaint = ComplaintModel(
        id: docRef.id,
        studentId: currentUser.uid,
        studentName: studentName,
        title: title,
        description: description,
        category: category,
        assignedDepartment: category.assignedDepartment,
        location: location,
        imageUrls: imageUrls,
        status: ComplaintStatus.pendingReview,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(complaint.toJson());
      return complaint;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to submit complaint: ${e.toString()}');
    }
  }

  @override
  Stream<List<ComplaintModel>> getMyComplaints(String studentId) {
    return _complaintsRef
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromJson(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<ComplaintModel> getComplaintById(String id) async {
    try {
      final doc = await _complaintsRef.doc(id).get();
      if (!doc.exists) {
        throw const ServerException('Complaint not found.');
      }
      return ComplaintModel.fromJson(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      throw ServerException('Failed to load complaint.');
    }
  }

  @override
  Future<ComplaintModel> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus status,
  }) async {
    try {
      final before = await getComplaintById(complaintId);

      await _complaintsRef.doc(complaintId).update({
        'status': status.value,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await notificationWriter.send(
        recipientId: before.studentId,
        type: 'complaint_status',
        title: 'Complaint Update',
        body: 'Your complaint "${before.title}" is now ${status.displayName}.',
        actionRoute: '/complaint/$complaintId',
      );

      return getComplaintById(complaintId);
    } catch (e) {
      throw ServerException('Failed to update complaint: ${e.toString()}');
    }
  }

  @override
  Stream<List<ComplaintModel>> getComplaintsByDepartment(String department) {
    return _complaintsRef
        .where('assignedDepartment', isEqualTo: department)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromJson(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }
}
