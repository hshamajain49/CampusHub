import 'package:equatable/equatable.dart';
import '../../../../venues/domain/entities/venue_entity.dart';

abstract class VenueActionState extends Equatable {
  const VenueActionState();
  @override
  List<Object?> get props => [];
}

class VenueActionInitial extends VenueActionState {
  const VenueActionInitial();
}

class VenueActionLoading extends VenueActionState {
  const VenueActionLoading();
}

class VenueActionSuccess extends VenueActionState {
  final VenueEntity venue;
  const VenueActionSuccess(this.venue);
  @override
  List<Object?> get props => [venue];
}

class VenueActionError extends VenueActionState {
  final String message;
  const VenueActionError(this.message);
  @override
  List<Object?> get props => [message];
}
