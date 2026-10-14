import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../notifications/data/notification_writer.dart';
import '../../../venues/domain/entities/booking_status.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

/// Removes or anonymises everything in Firestore that belongs to one account.
///
/// Shared by self-service deletion (AuthRemoteDataSource) and admin deletion
/// (AdminRemoteDataSource) so both follow the same data policy:
///
/// * Deleted: the profile, the user's notifications, suggestions they wrote
///   and their votes on other suggestions.
/// * Kept but anonymised: complaints and bookings. Staff and coordinators
///   still act on them and they feed the reports, so only the name is removed.
///   Pending and upcoming bookings are cancelled to free the venue.
/// * Recorded: a `deleted_accounts/{uid}` tombstone (no personal data) so the
///   leftover Firebase Auth sign-in can be removed the next time it is used.
class AccountDataCleaner {
  static const String deletedUserName = 'Deleted user';
  static const String tombstoneCollection = 'deleted_accounts';

  final FirebaseFirestore firestore;
  final NotificationWriter notificationWriter;

  const AccountDataCleaner({
    required this.firestore,
    required this.notificationWriter,
  });

  // Reads go to the server: a partial offline cache would leave data behind,
  // and failing fast offline beats queuing writes that never complete.
  static const _server = GetOptions(source: Source.server);

  /// Throws [ServerException] when deleting [user] would leave the app in a
  /// broken state (venues without a coordinator, or no admin left).
  Future<void> ensureDeletable(UserModel user, {required bool isSelf}) async {
    try {
      final venues = await firestore
          .collection('venues')
          .where('coordinatorId', isEqualTo: user.uid)
          .get(_server);
      if (venues.docs.isNotEmpty) {
        final count = venues.docs.length;
        final venuesLabel = count == 1 ? '1 venue' : '$count venues';
        throw ServerException(
          isSelf
              ? "You're the coordinator for $venuesLabel. Ask an admin to "
                    'assign ${count == 1 ? 'it' : 'them'} to someone else '
                    'before deleting your account.'
              : '${user.name} coordinates $venuesLabel. Assign '
                    '${count == 1 ? 'it' : 'them'} to another coordinator in '
                    'Manage Venues first.',
        );
      }

      if (user.role == UserRole.admin) {
        final admins = await firestore
            .collection('users')
            .where('role', isEqualTo: UserRole.admin.value)
            .get(_server);
        final otherActiveAdmins = admins.docs.where(
          (d) => d.id != user.uid && (d.data()['isActive'] as bool? ?? true),
        );
        if (otherActiveAdmins.isEmpty) {
          throw ServerException(
            isSelf
                ? "You're the only active admin. Make someone else an admin "
                      'before deleting your account.'
                : '${user.name} is the only active admin and cannot be deleted.',
          );
        }
      }
    } on FirebaseException catch (e) {
      throw ServerException(messageFor(e));
    }
  }

  /// Deletes or anonymises all data for [uid], then removes the profile.
  ///
  /// [deletedBy] must be the signed-in user's uid (the account itself or the
  /// admin performing the deletion). Every step is idempotent and the profile
  /// is removed last, so a failure part-way leaves a working account that
  /// can simply be deleted again.
  Future<void> purge({required String uid, required String deletedBy}) async {
    try {
      final results = await Future.wait([
        _where('notifications', 'recipientId', uid),
        _where('suggestions', 'authorId', uid),
        firestore
            .collection('suggestions')
            .where('upvotedBy', arrayContains: uid)
            .get(_server),
        _where('complaints', 'studentId', uid),
        _where('bookings', 'studentId', uid),
        _where('bookings', 'coordinatorId', uid),
      ]);
      final notifications = results[0].docs;
      final suggestions = results[1].docs;
      final upvoted = results[2].docs;
      final complaints = results[3].docs;
      final ownBookings = results[4].docs;
      final assignedBookings = results[5].docs;

      final authoredIds = suggestions.map((d) => d.id).toSet();
      await _runAll([
        for (final doc in notifications) doc.reference.delete,
        for (final doc in suggestions) doc.reference.delete,
        for (final doc in upvoted)
          if (!authoredIds.contains(doc.id))
            () => doc.reference.update({
              'upvotedBy': FieldValue.arrayRemove([uid]),
            }),
        for (final doc in complaints)
          if (doc.data()['studentName'] != deletedUserName)
            () => doc.reference.update({'studentName': deletedUserName}),
        for (final doc in ownBookings) () => _releaseBooking(doc, uid),
      ]);

      await _handOverPendingRequests(
        assignedBookings.where((d) => d.data()['studentId'] != uid),
        uid,
      );

      // Tombstone + profile removal in one atomic step.
      final batch = firestore.batch()
        ..set(firestore.collection(tombstoneCollection).doc(uid), {
          'uid': uid,
          'deletedBy': deletedBy,
          'deletedAt': FieldValue.serverTimestamp(),
        })
        ..delete(firestore.collection('users').doc(uid));
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(messageFor(e));
    }
  }

  /// Whether [uid] belonged to an account deleted through [purge].
  Future<bool> isDeleted(String uid) async {
    final doc = await firestore
        .collection(tombstoneCollection)
        .doc(uid)
        .get(_server);
    return doc.exists;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _where(
    String collection,
    String field,
    String uid,
  ) {
    return firestore
        .collection(collection)
        .where(field, isEqualTo: uid)
        .get(_server);
  }

  /// Anonymises a booking the user made, cancelling it if it still holds the
  /// venue (pending, or approved and not yet over).
  Future<void> _releaseBooking(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String uid,
  ) async {
    final data = doc.data();
    final status = BookingStatus.fromString(data['status'] as String? ?? '');
    final endDate = DateTime.tryParse(data['endDate'] as String? ?? '');
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final holdsVenue =
        status == BookingStatus.pending ||
        (status == BookingStatus.approved &&
            endDate != null &&
            !endDate.isBefore(startOfToday));

    await doc.reference.update({
      'studentName': deletedUserName,
      if (holdsVenue) ...{
        'status': BookingStatus.cancelled.value,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    });

    final coordinatorId = data['coordinatorId'] as String? ?? '';
    if (holdsVenue && coordinatorId.isNotEmpty && coordinatorId != uid) {
      await notificationWriter.send(
        recipientId: coordinatorId,
        type: 'booking_cancelled',
        title: 'Booking Cancelled',
        body:
            'The booking for ${data['venueName']} was cancelled because the '
            "requester's account was deleted.",
        actionRoute: '/approval/${doc.id}',
      );
    }
  }

  /// Moves pending requests still addressed to a deleted coordinator over to
  /// whoever coordinates the venue now, so they don't sit unanswered.
  Future<void> _handOverPendingRequests(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> bookings,
    String uid,
  ) async {
    final pending = bookings
        .where((d) => d.data()['status'] == BookingStatus.pending.value)
        .toList();
    if (pending.isEmpty) return;

    final venueCoordinators = <String, String>{};
    for (final venueId in pending.map((d) => d.data()['venueId'] as String)) {
      if (venueCoordinators.containsKey(venueId)) continue;
      final venue = await firestore
          .collection('venues')
          .doc(venueId)
          .get(_server);
      venueCoordinators[venueId] =
          venue.data()?['coordinatorId'] as String? ?? '';
    }

    await _runAll([
      for (final doc in pending)
        if (venueCoordinators[doc.data()['venueId']] case final next?
            when next.isNotEmpty && next != uid)
          () => doc.reference.update({'coordinatorId': next}),
    ]);
  }

  /// Runs writes in small concurrent groups. Individual writes (rather than
  /// one big batch) keep each request inside the security-rules limit on
  /// document lookups.
  static Future<void> _runAll(List<Future<void> Function()> tasks) async {
    const groupSize = 20;
    for (var i = 0; i < tasks.length; i += groupSize) {
      await Future.wait(tasks.skip(i).take(groupSize).map((task) => task()));
    }
  }

  static String messageFor(FirebaseException e) {
    switch (e.code) {
      case 'unavailable':
      case 'deadline-exceeded':
        return 'You appear to be offline. Check your connection and try again.';
      case 'permission-denied':
        return "You don't have permission to delete this account.";
      default:
        return 'Could not delete the account. Please try again.';
    }
  }
}
