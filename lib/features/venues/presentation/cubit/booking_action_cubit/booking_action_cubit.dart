import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/booking_entity.dart';
import '../../../domain/usecases/update_booking_usecase.dart';
import '../../../domain/usecases/cancel_booking_usecase.dart';
import 'booking_action_state.dart';

class BookingActionCubit extends Cubit<BookingActionState> {
  final UpdateBookingUseCase updateBookingUseCase;
  final CancelBookingUseCase cancelBookingUseCase;

  BookingActionCubit({
    required this.updateBookingUseCase,
    required this.cancelBookingUseCase,
  }) : super(const BookingActionInitial());

  Future<void> update({
    required BookingEntity original,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  }) async {
    emit(const BookingActionLoading());
    final result = await updateBookingUseCase(
      original: original,
      purpose: purpose,
      startDate: startDate,
      endDate: endDate,
      isFullDay: isFullDay,
      startTime: startTime,
      endTime: endTime,
    );
    result.fold(
      (failure) => emit(BookingActionError(failure.message)),
      (booking) => emit(BookingUpdateSuccess(booking)),
    );
  }

  Future<void> cancel(String bookingId) async {
    emit(const BookingActionLoading());
    final result = await cancelBookingUseCase(bookingId);
    result.fold(
      (failure) => emit(BookingActionError(failure.message)),
      (_) => emit(const BookingCancelSuccess()),
    );
  }
}
