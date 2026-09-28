import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/approve_booking_usecase.dart';
import '../../../domain/usecases/reject_booking_usecase.dart';
import 'approval_action_state.dart';

class ApprovalActionCubit extends Cubit<ApprovalActionState> {
  final ApproveBookingUseCase approveBookingUseCase;
  final RejectBookingUseCase rejectBookingUseCase;

  ApprovalActionCubit({
    required this.approveBookingUseCase,
    required this.rejectBookingUseCase,
  }) : super(const ApprovalActionInitial());

  Future<void> approve(String bookingId) async {
    emit(const ApprovalActionLoading());
    final result = await approveBookingUseCase(bookingId);
    result.fold(
      (failure) => emit(ApprovalActionError(failure.message)),
      (booking) => emit(ApprovalActionSuccess(booking)),
    );
  }

  Future<void> reject(String bookingId, String reason) async {
    emit(const ApprovalActionLoading());
    final result = await rejectBookingUseCase(bookingId, reason);
    result.fold(
      (failure) => emit(ApprovalActionError(failure.message)),
      (booking) => emit(ApprovalActionSuccess(booking)),
    );
  }
}
