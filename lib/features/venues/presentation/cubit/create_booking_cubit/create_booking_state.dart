import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_entity.dart';

abstract class CreateBookingState extends Equatable {
  const CreateBookingState();
  @override
  List<Object?> get props => [];
}

class CreateBookingInitial extends CreateBookingState {
  const CreateBookingInitial();
}

class CreateBookingLoading extends CreateBookingState {
  const CreateBookingLoading();
}

class CreateBookingSuccess extends CreateBookingState {
  final BookingEntity booking;
  const CreateBookingSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class CreateBookingError extends CreateBookingState {
  final String message;
  const CreateBookingError(this.message);

  @override
  List<Object?> get props => [message];
}
