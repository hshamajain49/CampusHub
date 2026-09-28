import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/complaint_status.dart';
import '../../../domain/usecases/get_complaints_by_department_usecase.dart';
import 'staff_complaints_state.dart';

class StaffComplaintsCubit extends Cubit<StaffComplaintsState> {
  final GetComplaintsByDepartmentUseCase getComplaintsByDepartmentUseCase;
  StreamSubscription? _subscription;

  StaffComplaintsCubit({required this.getComplaintsByDepartmentUseCase})
    : super(const StaffComplaintsLoading());

  void load(String department) {
    if (department.isEmpty) {
      emit(
        const StaffComplaintsError(
          'Your account has no department assigned. Contact an admin to set this up.',
        ),
      );
      return;
    }
    _subscription?.cancel();
    _subscription = getComplaintsByDepartmentUseCase(department).listen(
      (complaints) {
        final active = complaints
            .where((c) => c.status != ComplaintStatus.resolved)
            .toList();
        final resolved = complaints
            .where((c) => c.status == ComplaintStatus.resolved)
            .toList();
        emit(StaffComplaintsLoaded(active: active, resolved: resolved));
      },
      onError: (_) =>
          emit(const StaffComplaintsError('Failed to load complaints.')),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
