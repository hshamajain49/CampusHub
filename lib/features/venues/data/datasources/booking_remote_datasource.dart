import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../../notifications/data/notification_writer.dart';
import '../../domain/entities/booking_status.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<BookingModel>> getBookingsForVenue(String venueId);

  Future<BookingModel> createBooking({
    required String venueId,
    required String venueName,
    required String coordinatorId,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  });

  Stream<List<BookingModel>> getMyBookings(String studentId);

  Future<BookingModel> getBookingById(String bookingId);

  Future<BookingModel> updateBooking({
    required String bookingId,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
    required BookingStatus status,
  });

  Future<void> cancelBooking(String bookingId);

  Stream<List<BookingModel>> getBookingsForCoordinator(String coordinatorId);

  Future<BookingModel> approveBooking(String bookingId);

  Future<BookingModel> rejectBooking(String bookingId, String reason);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final NotificationWriter notificationWriter;

  BookingRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.notificationWriter,
  });

  CollectionReference get _bookingsRef => firestore.collection('bookings');

  @override
  Future<List<BookingModel>> getBookingsForVenue(String venueId) async {
    try {
      final snapshot = await _bookingsRef
          .where('venueId', isEqualTo: venueId)
          .where('status', whereIn: ['pending', 'approved'])
          .get();

      return snapshot.docs
          .map(
            (doc) => BookingModel.fromJson(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw const ServerException('Failed to check venue availability.');
    }
  }

  @override
  Future<BookingModel> createBooking({
    required String venueId,
    required String venueName,
    required String coordinatorId,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const AuthException('You must be logged in to book a venue.');
      }

      final userDoc = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final studentName = (userDoc.data()?['name'] as String?) ?? 'Unknown';

      final now = DateTime.now();
      final docRef = _bookingsRef.doc();

      final booking = BookingModel(
        id: docRef.id,
        venueId: venueId,
        venueName: venueName,
        studentId: currentUser.uid,
        studentName: studentName,
        coordinatorId: coordinatorId,
        purpose: purpose,
        startDate: startDate,
        endDate: endDate,
        isFullDay: isFullDay,
        startTime: startTime,
        endTime: endTime,
        status: BookingStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(booking.toJson());

      await notificationWriter.send(
        recipientId: coordinatorId,
        type: 'new_booking_request',
        title: 'New Booking Request',
        body: '$studentName requested $venueName.',
        actionRoute: '/approval/${docRef.id}',
      );

      return booking;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to submit booking: ${e.toString()}');
    }
  }

  @override
  Stream<List<BookingModel>> getMyBookings(String studentId) {
    return _bookingsRef
        .where('studentId', isEqualTo: studentId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => BookingModel.fromJson(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final doc = await _bookingsRef.doc(bookingId).get();
      if (!doc.exists) {
        throw const ServerException('Booking not found.');
      }
      return BookingModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw const ServerException('Failed to load booking.');
    }
  }

  @override
  Future<BookingModel> updateBooking({
    required String bookingId,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
    required BookingStatus status,
  }) async {
    try {
      await _bookingsRef.doc(bookingId).update({
        'purpose': purpose,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isFullDay': isFullDay,
        'startTime': startTime,
        'endTime': endTime,
        'status': status.value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return getBookingById(bookingId);
    } catch (e) {
      throw ServerException('Failed to update booking: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingsRef.doc(bookingId).update({
        'status': BookingStatus.cancelled.value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw const ServerException('Failed to cancel booking.');
    }
  }

  @override
  Stream<List<BookingModel>> getBookingsForCoordinator(String coordinatorId) {
    return _bookingsRef
        .where('coordinatorId', isEqualTo: coordinatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => BookingModel.fromJson(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<BookingModel> approveBooking(String bookingId) async {
    try {
      final before = await getBookingById(bookingId);

      await _bookingsRef.doc(bookingId).update({
        'status': BookingStatus.approved.value,
        'rejectionReason': null,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await notificationWriter.send(
        recipientId: before.studentId,
        type: 'booking_approved',
        title: 'Booking Approved',
        body: 'Your booking for ${before.venueName} was approved.',
        actionRoute: '/booking/$bookingId',
      );

      return getBookingById(bookingId);
    } catch (e) {
      throw const ServerException('Failed to approve booking.');
    }
  }

  @override
  Future<BookingModel> rejectBooking(String bookingId, String reason) async {
    try {
      final before = await getBookingById(bookingId);

      await _bookingsRef.doc(bookingId).update({
        'status': BookingStatus.rejected.value,
        'rejectionReason': reason,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await notificationWriter.send(
        recipientId: before.studentId,
        type: 'booking_rejected',
        title: 'Booking Rejected',
        body: 'Your booking for ${before.venueName} was rejected: $reason',
        actionRoute: '/booking/$bookingId',
      );

      return getBookingById(bookingId);
    } catch (e) {
      throw const ServerException('Failed to reject booking.');
    }
  }
}
