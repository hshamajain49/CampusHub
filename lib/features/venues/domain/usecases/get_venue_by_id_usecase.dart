import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/venue_entity.dart';
import '../repositories/venue_repository.dart';

class GetVenueByIdUseCase {
  final VenueRepository repository;
  const GetVenueByIdUseCase(this.repository);

  Future<Either<Failure, VenueEntity>> call(String id) =>
      repository.getVenueById(id);
}
