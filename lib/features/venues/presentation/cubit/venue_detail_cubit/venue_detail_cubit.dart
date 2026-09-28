import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_venue_by_id_usecase.dart';
import 'venue_detail_state.dart';

class VenueDetailCubit extends Cubit<VenueDetailState> {
  final GetVenueByIdUseCase getVenueByIdUseCase;
  VenueDetailCubit(this.getVenueByIdUseCase)
    : super(const VenueDetailLoading());

  Future<void> load(String venueId) async {
    emit(const VenueDetailLoading());
    final result = await getVenueByIdUseCase(venueId);
    result.fold(
      (failure) => emit(VenueDetailError(failure.message)),
      (venue) => emit(VenueDetailLoaded(venue)),
    );
  }
}
