import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_booking_by_id_usecase.dart';
import 'booking_detail_state.dart';

class BookingDetailCubit extends Cubit<BookingDetailState> {
  final GetBookingByIdUseCase getBookingByIdUseCase;
  BookingDetailCubit(this.getBookingByIdUseCase)
    : super(const BookingDetailLoading());

  Future<void> load(String bookingId) async {
    emit(const BookingDetailLoading());
    final result = await getBookingByIdUseCase(bookingId);
    result.fold(
      (failure) => emit(BookingDetailError(failure.message)),
      (booking) => emit(BookingDetailLoaded(booking)),
    );
  }
}
