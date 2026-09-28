import 'package:equatable/equatable.dart';
import '../../../domain/entities/complaint_entity.dart';

abstract class CreateComplaintState extends Equatable {
  const CreateComplaintState();
  @override
  List<Object?> get props => [];
}

class CreateComplaintInitial extends CreateComplaintState {
  const CreateComplaintInitial();
}

class CreateComplaintLoading extends CreateComplaintState {
  const CreateComplaintLoading();
}

class CreateComplaintSuccess extends CreateComplaintState {
  final ComplaintEntity complaint;
  const CreateComplaintSuccess(this.complaint);

  @override
  List<Object?> get props => [complaint];
}

class CreateComplaintError extends CreateComplaintState {
  final String message;
  const CreateComplaintError(this.message);

  @override
  List<Object?> get props => [message];
}
