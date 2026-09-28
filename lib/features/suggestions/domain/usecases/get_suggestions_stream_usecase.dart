import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/suggestion_entity.dart';
import '../repositories/suggestion_repository.dart';

class GetSuggestionsStreamUseCase {
  final SuggestionRepository repository;
  const GetSuggestionsStreamUseCase(this.repository);

  Stream<Either<Failure, List<SuggestionEntity>>> call() =>
      repository.getSuggestionsStream();
}
