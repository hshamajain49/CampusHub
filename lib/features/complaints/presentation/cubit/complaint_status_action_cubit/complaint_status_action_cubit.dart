import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/complaint_status.dart';
import '../../../domain/usecases/review_complaint_resolution_usecase.dart';
import '../../../domain/usecases/update_complaint_status_usecase.dart';
import 'complaint_status_action_state.dart';

class ComplaintStatusActionCubit extends Cubit<ComplaintStatusActionState> {
  final UpdateComplaintStatusUseCase updateComplaintStatusUseCase;
  final ReviewComplaintResolutionUseCase reviewComplaintResolutionUseCase;
  ComplaintStatusActionCubit(
    this.updateComplaintStatusUseCase,
    this.reviewComplaintResolutionUseCase,
  ) : super(const ComplaintStatusActionInitial());

  Future<void> updateStatus(String complaintId, ComplaintStatus status) async {
    emit(const ComplaintStatusActionLoading());
    final result = await updateComplaintStatusUseCase(
      complaintId: complaintId,
      status: status,
    );
    result.fold(
      (failure) => emit(ComplaintStatusActionError(failure.message)),
      (complaint) => emit(ComplaintStatusActionSuccess(complaint)),
    );
  }

  Future<void> reviewResolution(
    String complaintId, {
    required bool approved,
    String? reason,
  }) async {
    emit(const ComplaintStatusActionLoading());
    final result = await reviewComplaintResolutionUseCase(
      complaintId: complaintId,
      approved: approved,
      reason: reason,
    );
    result.fold(
      (failure) => emit(ComplaintStatusActionError(failure.message)),
      (complaint) => emit(ComplaintStatusActionSuccess(complaint)),
    );
  }
}
