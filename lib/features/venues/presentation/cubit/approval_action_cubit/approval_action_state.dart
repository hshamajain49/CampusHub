import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_entity.dart';

abstract class ApprovalActionState extends Equatable {
  const ApprovalActionState();
  @override
  List<Object?> get props => [];
}

class ApprovalActionInitial extends ApprovalActionState {
  const ApprovalActionInitial();
}

class ApprovalActionLoading extends ApprovalActionState {
  const ApprovalActionLoading();
}

class ApprovalActionSuccess extends ApprovalActionState {
  final BookingEntity booking;
  const ApprovalActionSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class ApprovalActionError extends ApprovalActionState {
  final String message;
  const ApprovalActionError(this.message);
  @override
  List<Object?> get props => [message];
}
