import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../complaints/data/models/complaint_model.dart';
import '../../../venues/data/models/booking_model.dart';

abstract class ReportsRemoteDataSource {
  Future<List<ComplaintModel>> getAllComplaints();
  Future<List<BookingModel>> getAllBookings();
  Future<List<UserModel>> getAllUsersOnce();
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final FirebaseFirestore firestore;
  ReportsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ComplaintModel>> getAllComplaints() async {
    try {
      final snapshot = await firestore.collection('complaints').get();
      return snapshot.docs
          .map((doc) => ComplaintModel.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw const ServerException(
        'Failed to load complaints data for the report.',
      );
    }
  }

  @override
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final snapshot = await firestore.collection('bookings').get();
      return snapshot.docs
          .map((doc) => BookingModel.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw const ServerException(
        'Failed to load bookings data for the report.',
      );
    }
  }

  @override
  Future<List<UserModel>> getAllUsersOnce() async {
    try {
      final snapshot = await firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw const ServerException('Failed to load user data for the report.');
    }
  }
}
