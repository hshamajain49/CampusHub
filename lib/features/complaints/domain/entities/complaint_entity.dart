import 'package:equatable/equatable.dart';
import 'complaint_category.dart';
import 'complaint_status.dart';

class ComplaintEntity extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String title;
  final String? description;
  final ComplaintCategory category;
  final String assignedDepartment;
  final String? location;
  final List<String> imageUrls; // Cloudinary URLs, up to 3
  final ComplaintStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ComplaintEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.title,
    this.description,
    required this.category,
    required this.assignedDepartment,
    this.location,
    this.imageUrls = const [],
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    title,
    description,
    category,
    assignedDepartment,
    location,
    imageUrls,
    status,
    createdAt,
    updatedAt,
  ];
}
