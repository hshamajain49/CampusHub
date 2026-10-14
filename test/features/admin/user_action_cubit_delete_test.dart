import 'package:bloc_test/bloc_test.dart';
import 'package:campus_hub/core/error/failure.dart';
import 'package:campus_hub/features/admin/domain/repositories/admin_repository.dart';
import 'package:campus_hub/features/admin/domain/usecases/create_manage_user_usecase.dart';
import 'package:campus_hub/features/admin/domain/usecases/delete_user_account_usecase.dart';
import 'package:campus_hub/features/admin/domain/usecases/send_password_reset_usecase.dart';
import 'package:campus_hub/features/admin/domain/usecases/update_user_active_status_usecase.dart';
import 'package:campus_hub/features/admin/domain/usecases/update_user_role_usecase.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late MockAdminRepository repository;

  setUp(() => repository = MockAdminRepository());

  UserActionCubit build() => UserActionCubit(
    createManagedUserUseCase: CreateManagedUserUseCase(repository),
    updateUserRoleUseCase: UpdateUserRoleUseCase(repository),
    updateUserActiveStatusUseCase: UpdateUserActiveStatusUseCase(repository),
    sendPasswordResetUseCase: SendPasswordResetUseCase(repository),
    deleteUserAccountUseCase: DeleteUserAccountUseCase(repository),
  );

  blocTest<UserActionCubit, UserActionState>(
    'emits UserDeleting then UserDeleted with the name',
    setUp: () => when(
      () => repository.deleteUserAccount('u1'),
    ).thenAnswer((_) async => const Right(null)),
    build: build,
    act: (cubit) => cubit.deleteUser(uid: 'u1', name: 'Sam'),
    expect: () => const [UserDeleting(), UserDeleted('Sam')],
  );

  blocTest<UserActionCubit, UserActionState>(
    'emits the failure message when deletion is refused',
    setUp: () => when(() => repository.deleteUserAccount('u1')).thenAnswer(
      (_) async => const Left(ServerFailure('Assign venues first.')),
    ),
    build: build,
    act: (cubit) => cubit.deleteUser(uid: 'u1', name: 'Sam'),
    expect: () => const [
      UserDeleting(),
      UserActionError('Assign venues first.'),
    ],
  );

  blocTest<UserActionCubit, UserActionState>(
    'does not start a deletion while another action is running',
    build: build,
    seed: () => const UserActionLoading(),
    act: (cubit) => cubit.deleteUser(uid: 'u1', name: 'Sam'),
    expect: () => const <UserActionState>[],
    verify: (_) => verifyNever(() => repository.deleteUserAccount(any())),
  );
}
