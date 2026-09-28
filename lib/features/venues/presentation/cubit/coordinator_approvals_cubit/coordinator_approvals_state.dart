import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_entity.dart';

abstract class CoordinatorApprovalsState extends Equatable {
  const CoordinatorApprovalsState();
  @override
  List<Object?> get props => [];
}

class CoordinatorApprovalsLoading extends CoordinatorApprovalsState {
  const CoordinatorApprovalsLoading();
}

class CoordinatorApprovalsLoaded extends CoordinatorApprovalsState {
  final List<BookingEntity> pending;
  final List<BookingEntity>
  history; // approved / rejected / cancelled, most recent first
  const CoordinatorApprovalsLoaded({
    required this.pending,
    required this.history,
  });

  @override
  List<Object?> get props => [pending, history];
}

class CoordinatorApprovalsError extends CoordinatorApprovalsState {
  final String message;
  const CoordinatorApprovalsError(this.message);
  @override
  List<Object?> get props => [message];
}
