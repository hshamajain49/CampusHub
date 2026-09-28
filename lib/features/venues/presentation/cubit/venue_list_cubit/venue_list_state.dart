import 'package:equatable/equatable.dart';
import '../../../domain/entities/venue_entity.dart';

abstract class VenueListState extends Equatable {
  const VenueListState();
  @override
  List<Object?> get props => [];
}

class VenueListLoading extends VenueListState {
  const VenueListLoading();
}

class VenueListLoaded extends VenueListState {
  final List<VenueEntity> venues;
  const VenueListLoaded(this.venues);

  @override
  List<Object?> get props => [venues];
}

class VenueListError extends VenueListState {
  final String message;
  const VenueListError(this.message);

  @override
  List<Object?> get props => [message];
}
