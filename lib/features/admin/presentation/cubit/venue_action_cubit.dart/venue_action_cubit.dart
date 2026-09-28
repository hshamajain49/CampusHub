import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../venues/domain/usecases/create_venue_usecase.dart';
import '../../../../venues/domain/usecases/update_venue_usecase.dart';
import 'venue_action_state.dart';

class VenueActionCubit extends Cubit<VenueActionState> {
  final CreateVenueUseCase createVenueUseCase;
  final UpdateVenueUseCase updateVenueUseCase;

  VenueActionCubit({
    required this.createVenueUseCase,
    required this.updateVenueUseCase,
  }) : super(const VenueActionInitial());

  Future<void> create({
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
  }) async {
    emit(const VenueActionLoading());
    final result = await createVenueUseCase(
      name: name,
      description: description,
      capacity: capacity,
      building: building,
      amenities: amenities,
      coordinatorId: coordinatorId,
    );
    result.fold(
      (failure) => emit(VenueActionError(failure.message)),
      (venue) => emit(VenueActionSuccess(venue)),
    );
  }

  Future<void> update({
    required String id,
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
    required bool isActive,
  }) async {
    emit(const VenueActionLoading());
    final result = await updateVenueUseCase(
      id: id,
      name: name,
      description: description,
      capacity: capacity,
      building: building,
      amenities: amenities,
      coordinatorId: coordinatorId,
      isActive: isActive,
    );
    result.fold(
      (failure) => emit(VenueActionError(failure.message)),
      (venue) => emit(VenueActionSuccess(venue)),
    );
  }
}
