import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:campus_hub/core/error/failure.dart';
import 'package:campus_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_hub/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:campus_hub/features/profile/presentation/cubit/delete_account_cubit/delete_account_cubit.dart';
import 'package:campus_hub/features/profile/presentation/cubit/delete_account_cubit/delete_account_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late DeleteAccountUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = DeleteAccountUseCase(repository);
  });

  group('DeleteAccountUseCase', () {
    test('rejects an empty password without calling the repository', () async {
      final result = await useCase(password: '');
      expect(result.isLeft(), isTrue);
      verifyNever(
        () => repository.deleteAccount(password: any(named: 'password')),
      );
    });
  });

  group('DeleteAccountCubit', () {
    blocTest<DeleteAccountCubit, DeleteAccountState>(
      'reports success and returns it',
      setUp: () => when(
        () => repository.deleteAccount(password: 'secret'),
      ).thenAnswer((_) async => const Right(null)),
      build: () => DeleteAccountCubit(useCase),
      act: (cubit) async =>
          expect((await cubit.deleteAccount('secret')).isRight(), isTrue),
      expect: () => const [DeleteAccountInProgress(), DeleteAccountSuccess()],
    );

    blocTest<DeleteAccountCubit, DeleteAccountState>(
      'reports the failure message and returns it',
      setUp: () =>
          when(() => repository.deleteAccount(password: 'wrong')).thenAnswer(
            (_) async => const Left(
              AuthFailure('Incorrect password. Please try again.'),
            ),
          ),
      build: () => DeleteAccountCubit(useCase),
      act: (cubit) async =>
          expect((await cubit.deleteAccount('wrong')).isLeft(), isTrue),
      expect: () => const [
        DeleteAccountInProgress(),
        DeleteAccountFailure('Incorrect password. Please try again.'),
      ],
    );

    blocTest<DeleteAccountCubit, DeleteAccountState>(
      'clearError resets a failure once the user edits the password',
      build: () => DeleteAccountCubit(useCase),
      seed: () => const DeleteAccountFailure('Incorrect password.'),
      act: (cubit) => cubit.clearError(),
      expect: () => const [DeleteAccountInitial()],
    );

    test('ignores a second tap while a deletion is running', () async {
      final pending = Completer<Either<Failure, void>>();
      when(
        () => repository.deleteAccount(password: 'secret'),
      ).thenAnswer((_) => pending.future);
      final cubit = DeleteAccountCubit(useCase);

      final first = cubit.deleteAccount('secret');
      expect((await cubit.deleteAccount('secret')).isLeft(), isTrue);
      pending.complete(const Right(null));
      expect((await first).isRight(), isTrue);
      verify(() => repository.deleteAccount(password: 'secret')).called(1);
      await cubit.close();
    });

    test('still reports success if the page closed it mid-deletion', () async {
      // Signing out after the deletion disposes the profile page.
      final pending = Completer<Either<Failure, void>>();
      when(
        () => repository.deleteAccount(password: 'secret'),
      ).thenAnswer((_) => pending.future);
      final cubit = DeleteAccountCubit(useCase);

      final result = cubit.deleteAccount('secret');
      await cubit.close();
      pending.complete(const Right(null));
      expect((await result).isRight(), isTrue);
    });

    test(
      'still returns the error if the page closed it mid-deletion',
      () async {
        // A failed final step signs the user out, disposing the profile page;
        // the caller must still be able to show why.
        const failure = AuthFailure('Sign in once more to finish.');
        final pending = Completer<Either<Failure, void>>();
        when(
          () => repository.deleteAccount(password: 'secret'),
        ).thenAnswer((_) => pending.future);
        final cubit = DeleteAccountCubit(useCase);

        final result = cubit.deleteAccount('secret');
        await cubit.close();
        pending.complete(const Left(failure));
        expect(await result, const Left<Failure, void>(failure));
      },
    );
  });
}
