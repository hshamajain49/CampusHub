import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_entity.dart';

abstract class BookingActionState extends Equatable {
  const BookingActionState();
  @override
  List<Object?> get props => [];
}

class BookingActionInitial extends BookingActionState {
  const BookingActionInitial();
}

class BookingActionLoading extends BookingActionState {
  const BookingActionLoading();
}

class BookingUpdateSuccess extends BookingActionState {
  final BookingEntity booking;
  const BookingUpdateSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class BookingCancelSuccess extends BookingActionState {
  const BookingCancelSuccess();
}

class BookingActionError extends BookingActionState {
  final String message;
  const BookingActionError(this.message);
  @override
  List<Object?> get props => [message];
}
