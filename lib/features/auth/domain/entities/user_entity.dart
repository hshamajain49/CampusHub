import 'package:equatable/equatable.dart';
import 'user_role.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? department;
  final bool isActive;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    name,
    role,
    department,
    isActive,
    createdAt,
  ];
}
