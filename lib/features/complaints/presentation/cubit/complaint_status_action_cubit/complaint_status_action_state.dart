import 'package:equatable/equatable.dart';
import '../../../domain/entities/complaint_entity.dart';

abstract class ComplaintStatusActionState extends Equatable {
  const ComplaintStatusActionState();
  @override
  List<Object?> get props => [];
}

class ComplaintStatusActionInitial extends ComplaintStatusActionState {
  const ComplaintStatusActionInitial();
}

class ComplaintStatusActionLoading extends ComplaintStatusActionState {
  const ComplaintStatusActionLoading();
}

class ComplaintStatusActionSuccess extends ComplaintStatusActionState {
  final ComplaintEntity complaint;
  const ComplaintStatusActionSuccess(this.complaint);
  @override
  List<Object?> get props => [complaint];
}

class ComplaintStatusActionError extends ComplaintStatusActionState {
  final String message;
  const ComplaintStatusActionError(this.message);
  @override
  List<Object?> get props => [message];
}
