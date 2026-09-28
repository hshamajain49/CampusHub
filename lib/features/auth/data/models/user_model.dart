import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.role,
    super.department,
    super.isActive,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      department: json['department'] as String?,
      isActive:
          json['isActive'] as bool? ??
          true, // default true for existing docs written before this field existed
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.value,
      'department': department,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
