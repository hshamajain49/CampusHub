import '../../domain/entities/venue_entity.dart';

class VenueModel extends VenueEntity {
  const VenueModel({
    required super.id,
    required super.name,
    required super.description,
    required super.capacity,
    required super.building,
    required super.amenities,
    required super.imageUrl,
    required super.isActive,
    required super.coordinatorId,
  });

  factory VenueModel.fromJson(String id, Map<String, dynamic> json) {
    return VenueModel(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      building: json['building'] as String? ?? '',
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      imageUrl: json['imageUrl'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      coordinatorId: json['coordinatorId'] as String? ?? '',
    );
  }
}
