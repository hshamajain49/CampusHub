import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_complaint_by_id_usecase.dart';
import 'complaint_detail_state.dart';

class ComplaintDetailCubit extends Cubit<ComplaintDetailState> {
  final GetComplaintByIdUseCase getComplaintByIdUseCase;
  ComplaintDetailCubit(this.getComplaintByIdUseCase)
    : super(const ComplaintDetailLoading());

  Future<void> load(String complaintId) async {
    emit(const ComplaintDetailLoading());
    final result = await getComplaintByIdUseCase(complaintId);
    result.fold(
      (failure) => emit(ComplaintDetailError(failure.message)),
      (complaint) => emit(ComplaintDetailLoaded(complaint)),
    );
  }
}
