import 'package:equatable/equatable.dart';
import '../../../domain/entities/venue_entity.dart';

abstract class VenueDetailState extends Equatable {
  const VenueDetailState();
  @override
  List<Object?> get props => [];
}

class VenueDetailLoading extends VenueDetailState {
  const VenueDetailLoading();
}

class VenueDetailLoaded extends VenueDetailState {
  final VenueEntity venue;
  const VenueDetailLoaded(this.venue);

  @override
  List<Object?> get props => [venue];
}

class VenueDetailError extends VenueDetailState {
  final String message;
  const VenueDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
