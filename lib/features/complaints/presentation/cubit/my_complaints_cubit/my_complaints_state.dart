import 'package:equatable/equatable.dart';
import '../../../domain/entities/complaint_entity.dart';

abstract class MyComplaintsState extends Equatable {
  const MyComplaintsState();
  @override
  List<Object?> get props => [];
}

class MyComplaintsLoading extends MyComplaintsState {
  const MyComplaintsLoading();
}

class MyComplaintsLoaded extends MyComplaintsState {
  final List<ComplaintEntity> complaints;
  const MyComplaintsLoaded(this.complaints);

  @override
  List<Object?> get props => [complaints];
}

class MyComplaintsError extends MyComplaintsState {
  final String message;
  const MyComplaintsError(this.message);

  @override
  List<Object?> get props => [message];
}
