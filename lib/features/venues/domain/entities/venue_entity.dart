import 'package:equatable/equatable.dart';

class VenueEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final String building;
  final List<String> amenities;
  final String imageUrl;
  final bool isActive;
  final String coordinatorId;

  const VenueEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.building,
    required this.amenities,
    required this.imageUrl,
    required this.isActive,
    required this.coordinatorId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    capacity,
    building,
    amenities,
    imageUrl,
    isActive,
    coordinatorId,
  ];
}
