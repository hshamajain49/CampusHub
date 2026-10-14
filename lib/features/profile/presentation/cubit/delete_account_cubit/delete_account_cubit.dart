import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failure.dart';
import '../../../../auth/domain/usecases/delete_account_usecase.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final DeleteAccountUseCase deleteAccountUseCase;
  DeleteAccountCubit(this.deleteAccountUseCase)
    : super(const DeleteAccountInitial());

  /// Also returns the outcome: the sign-out that accompanies a deletion (or
  /// a failed final step) can dispose the page, closing this cubit before a
  /// listener would see the resulting state, so callers act on the result.
  Future<Either<Failure, void>> deleteAccount(String password) async {
    if (state is DeleteAccountInProgress) {
      return const Left(AuthFailure('Your account is already being deleted.'));
    }
    _emitIfOpen(const DeleteAccountInProgress());
    final result = await deleteAccountUseCase(password: password);
    _emitIfOpen(
      result.fold(
        (failure) => DeleteAccountFailure(failure.message),
        (_) => const DeleteAccountSuccess(),
      ),
    );
    return result;
  }

  /// Clears a previous error once the user edits their input.
  void clearError() {
    if (state is DeleteAccountFailure) {
      _emitIfOpen(const DeleteAccountInitial());
    }
  }

  void _emitIfOpen(DeleteAccountState next) {
    if (!isClosed) emit(next);
  }
}
