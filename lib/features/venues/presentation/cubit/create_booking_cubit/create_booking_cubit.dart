import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_booking_usecase.dart';
import 'create_booking_state.dart';

class CreateBookingCubit extends Cubit<CreateBookingState> {
  final CreateBookingUseCase createBookingUseCase;
  CreateBookingCubit(this.createBookingUseCase)
    : super(const CreateBookingInitial());

  Future<void> submit({
    required String venueId,
    required String venueName,
    required String coordinatorId,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  }) async {
    emit(const CreateBookingLoading());

    final result = await createBookingUseCase(
      venueId: venueId,
      venueName: venueName,
      coordinatorId: coordinatorId,
      purpose: purpose,
      startDate: startDate,
      endDate: endDate,
      isFullDay: isFullDay,
      startTime: startTime,
      endTime: endTime,
    );

    result.fold(
      (failure) => emit(CreateBookingError(failure.message)),
      (booking) => emit(CreateBookingSuccess(booking)),
    );
  }
}
