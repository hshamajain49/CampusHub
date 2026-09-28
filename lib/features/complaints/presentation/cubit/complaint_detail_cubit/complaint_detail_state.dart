import 'package:equatable/equatable.dart';
import '../../../domain/entities/complaint_entity.dart';

abstract class ComplaintDetailState extends Equatable {
  const ComplaintDetailState();
  @override
  List<Object?> get props => [];
}

class ComplaintDetailLoading extends ComplaintDetailState {
  const ComplaintDetailLoading();
}

class ComplaintDetailLoaded extends ComplaintDetailState {
  final ComplaintEntity complaint;
  const ComplaintDetailLoaded(this.complaint);

  @override
  List<Object?> get props => [complaint];
}

class ComplaintDetailError extends ComplaintDetailState {
  final String message;
  const ComplaintDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
