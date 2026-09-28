import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_entity.dart';

abstract class BookingDetailState extends Equatable {
  const BookingDetailState();
  @override
  List<Object?> get props => [];
}

class BookingDetailLoading extends BookingDetailState {
  const BookingDetailLoading();
}

class BookingDetailLoaded extends BookingDetailState {
  final BookingEntity booking;
  const BookingDetailLoaded(this.booking);
  @override
  List<Object?> get props => [booking];
}

class BookingDetailError extends BookingDetailState {
  final String message;
  const BookingDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
