import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_venues_usecase.dart';
import 'venue_list_state.dart';

class VenueListCubit extends Cubit<VenueListState> {
  final GetVenuesUseCase getVenuesUseCase;
  StreamSubscription? _subscription;

  VenueListCubit(this.getVenuesUseCase) : super(const VenueListLoading()) {
    _subscription = getVenuesUseCase().listen(
      (venues) => emit(VenueListLoaded(venues)),
      onError: (_) => emit(const VenueListError('Failed to load venues.')),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
