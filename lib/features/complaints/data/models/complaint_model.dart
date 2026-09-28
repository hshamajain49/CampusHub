import '../../domain/entities/complaint_entity.dart';
import '../../domain/entities/complaint_category.dart';
import '../../domain/entities/complaint_status.dart';

class ComplaintModel extends ComplaintEntity {
  const ComplaintModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.title,
    super.description,
    required super.category,
    required super.assignedDepartment,
    super.location,
    super.imageUrls,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ComplaintModel.fromJson(String id, Map<String, dynamic> json) {
    return ComplaintModel(
      id: id,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: ComplaintCategory.fromString(json['category'] as String),
      assignedDepartment: json['assignedDepartment'] as String,
      location: json['location'] as String?,
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      status: ComplaintStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'title': title,
      'description': description,
      'category': category.value,
      'assignedDepartment': assignedDepartment,
      'location': location,
      'imageUrls': imageUrls,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
