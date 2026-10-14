import 'package:equatable/equatable.dart';
import '../../../../auth/domain/entities/user_entity.dart';

abstract class UserActionState extends Equatable {
  const UserActionState();
  @override
  List<Object?> get props => [];
}

class UserActionInitial extends UserActionState {
  const UserActionInitial();
}

class UserActionLoading extends UserActionState {
  const UserActionLoading();
}

class UserActionError extends UserActionState {
  final String message;
  const UserActionError(this.message);
  @override
  List<Object?> get props => [message];
}

/// A new managed account was created (Create User page listens for this).
class UserCreated extends UserActionState {
  final UserEntity user;
  const UserCreated(this.user);
  @override
  List<Object?> get props => [user];
}

/// Role/department was updated (Edit User page pops on this).
class UserRoleUpdated extends UserActionState {
  const UserRoleUpdated();
}

/// Active status was toggled (Edit User page stays open, shows a snackbar).
class UserActiveStatusChanged extends UserActionState {
  final bool isActive;
  const UserActiveStatusChanged(this.isActive);
  @override
  List<Object?> get props => [isActive];
}

/// Password reset email was sent (Edit User page stays open, shows a snackbar).
class PasswordResetSent extends UserActionState {
  const PasswordResetSent();
}

/// An account deletion is in progress (only the Delete button shows a spinner).
class UserDeleting extends UserActionLoading {
  const UserDeleting();
}

/// The account was deleted (Edit User page pops back to the list).
class UserDeleted extends UserActionState {
  final String name;
  const UserDeleted(this.name);
  @override
  List<Object?> get props => [name];
}
