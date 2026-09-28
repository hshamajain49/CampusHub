import 'package:campus_hub/features/admin/domain/usecases/create_manage_user_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/domain/entities/user_role.dart';
import '../../../domain/usecases/send_password_reset_usecase.dart';
import '../../../domain/usecases/update_user_active_status_usecase.dart';
import '../../../domain/usecases/update_user_role_usecase.dart';
import 'user_action_state.dart';

class UserActionCubit extends Cubit<UserActionState> {
  final CreateManagedUserUseCase createManagedUserUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;
  final UpdateUserActiveStatusUseCase updateUserActiveStatusUseCase;
  final SendPasswordResetUseCase sendPasswordResetUseCase;

  UserActionCubit({
    required this.createManagedUserUseCase,
    required this.updateUserRoleUseCase,
    required this.updateUserActiveStatusUseCase,
    required this.sendPasswordResetUseCase,
  }) : super(const UserActionInitial());

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
  }) async {
    emit(const UserActionLoading());
    final result = await createManagedUserUseCase(
      name: name,
      email: email,
      password: password,
      role: role,
      department: department,
    );
    result.fold(
      (failure) => emit(UserActionError(failure.message)),
      (user) => emit(UserCreated(user)),
    );
  }

  Future<void> updateRole({
    required String uid,
    required UserRole role,
    String? department,
  }) async {
    emit(const UserActionLoading());
    final result = await updateUserRoleUseCase(
      uid: uid,
      role: role,
      department: department,
    );
    result.fold(
      (failure) => emit(UserActionError(failure.message)),
      (_) => emit(const UserRoleUpdated()),
    );
  }

  Future<void> setActiveStatus({
    required String uid,
    required bool isActive,
  }) async {
    emit(const UserActionLoading());
    final result = await updateUserActiveStatusUseCase(
      uid: uid,
      isActive: isActive,
    );
    result.fold(
      (failure) => emit(UserActionError(failure.message)),
      (_) => emit(UserActiveStatusChanged(isActive)),
    );
  }

  Future<void> resetPassword(String email) async {
    emit(const UserActionLoading());
    final result = await sendPasswordResetUseCase(email);
    result.fold(
      (failure) => emit(UserActionError(failure.message)),
      (_) => emit(const PasswordResetSent()),
    );
  }
}
