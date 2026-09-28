import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_entity.dart';

abstract class MyBookingsState extends Equatable {
  const MyBookingsState();
  @override
  List<Object?> get props => [];
}

class MyBookingsLoading extends MyBookingsState {
  const MyBookingsLoading();
}

class MyBookingsLoaded extends MyBookingsState {
  final List<BookingEntity> bookings;
  const MyBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class MyBookingsError extends MyBookingsState {
  final String message;
  const MyBookingsError(this.message);

  @override
  List<Object?> get props => [message];
}
