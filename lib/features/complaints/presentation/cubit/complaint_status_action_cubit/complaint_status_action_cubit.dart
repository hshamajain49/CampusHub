import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/complaint_status.dart';
import '../../../domain/usecases/update_complaint_status_usecase.dart';
import 'complaint_status_action_state.dart';

class ComplaintStatusActionCubit extends Cubit<ComplaintStatusActionState> {
  final UpdateComplaintStatusUseCase updateComplaintStatusUseCase;
  ComplaintStatusActionCubit(this.updateComplaintStatusUseCase)
    : super(const ComplaintStatusActionInitial());

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
}
