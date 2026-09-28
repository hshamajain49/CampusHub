import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/venue_model.dart';

abstract class VenueRemoteDataSource {
  Stream<List<VenueModel>> getVenues();

  Future<VenueModel> getVenueById(String id);

  Future<VenueModel> createVenue({
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
  });

  Future<VenueModel> updateVenue({
    required String id,
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
    required bool isActive,
  });
}

class VenueRemoteDataSourceImpl implements VenueRemoteDataSource {
  final FirebaseFirestore firestore;
  VenueRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _venuesRef => firestore.collection('venues');

  @override
  Stream<List<VenueModel>> getVenues() {
    return _venuesRef.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                VenueModel.fromJson(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  Future<VenueModel> getVenueById(String id) async {
    try {
      final doc = await _venuesRef.doc(id).get();
      if (!doc.exists) {
        throw const ServerException('Venue not found.');
      }
      return VenueModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw const ServerException('Failed to load venue.');
    }
  }

  @override
  Future<VenueModel> createVenue({
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
  }) async {
    try {
      final docRef = _venuesRef.doc();
      final venue = VenueModel(
        id: docRef.id,
        name: name,
        description: description,
        capacity: capacity,
        building: building,
        amenities: amenities,
        imageUrl: '',
        isActive: true,
        coordinatorId: coordinatorId,
      );
      await docRef.set({
        'name': venue.name,
        'description': venue.description,
        'capacity': venue.capacity,
        'building': venue.building,
        'amenities': venue.amenities,
        'imageUrl': venue.imageUrl,
        'isActive': venue.isActive,
        'coordinatorId': venue.coordinatorId,
      });
      return venue;
    } catch (e) {
      throw ServerException('Failed to create venue: ${e.toString()}');
    }
  }

  @override
  Future<VenueModel> updateVenue({
    required String id,
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
    required bool isActive,
  }) async {
    try {
      await _venuesRef.doc(id).update({
        'name': name,
        'description': description,
        'capacity': capacity,
        'building': building,
        'amenities': amenities,
        'coordinatorId': coordinatorId,
        'isActive': isActive,
      });
      return getVenueById(id);
    } catch (e) {
      throw ServerException('Failed to update venue: ${e.toString()}');
    }
  }
}
