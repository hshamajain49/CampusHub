import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.venueId,
    required super.venueName,
    required super.studentId,
    required super.studentName,
    required super.coordinatorId,
    required super.purpose,
    required super.startDate,
    required super.endDate,
    required super.isFullDay,
    super.startTime,
    super.endTime,
    required super.status,
    super.rejectionReason,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BookingModel.fromJson(String id, Map<String, dynamic> json) {
    return BookingModel(
      id: id,
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      coordinatorId: json['coordinatorId'] as String? ?? '',
      purpose: json['purpose'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isFullDay: json['isFullDay'] as bool,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      status: BookingStatus.fromString(json['status'] as String),
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'venueId': venueId,
      'venueName': venueName,
      'studentId': studentId,
      'studentName': studentName,
      'coordinatorId': coordinatorId,
      'purpose': purpose,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isFullDay': isFullDay,
      'startTime': startTime,
      'endTime': endTime,
      'status': status.value,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
