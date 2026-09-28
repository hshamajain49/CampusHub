import 'package:equatable/equatable.dart';
import '../../../../auth/domain/entities/user_entity.dart';

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();
  @override
  List<Object?> get props => [];
}

class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading();
}

class AdminUsersLoaded extends AdminUsersState {
  final List<UserEntity> users;
  const AdminUsersLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class AdminUsersError extends AdminUsersState {
  final String message;
  const AdminUsersError(this.message);
  @override
  List<Object?> get props => [message];
}
