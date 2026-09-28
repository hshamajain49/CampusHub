import 'package:equatable/equatable.dart';
import '../../../domain/entities/complaint_entity.dart';

abstract class StaffComplaintsState extends Equatable {
  const StaffComplaintsState();
  @override
  List<Object?> get props => [];
}

class StaffComplaintsLoading extends StaffComplaintsState {
  const StaffComplaintsLoading();
}

class StaffComplaintsLoaded extends StaffComplaintsState {
  final List<ComplaintEntity> active; // unassigned / pendingReview / inProgress
  final List<ComplaintEntity> resolved;
  const StaffComplaintsLoaded({required this.active, required this.resolved});

  @override
  List<Object?> get props => [active, resolved];
}

class StaffComplaintsError extends StaffComplaintsState {
  final String message;
  const StaffComplaintsError(this.message);
  @override
  List<Object?> get props => [message];
}
