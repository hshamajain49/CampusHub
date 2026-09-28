import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/suggestion_entity.dart';

abstract class SuggestionRepository {
  Stream<Either<Failure, List<SuggestionEntity>>> getSuggestionsStream();

  Future<Either<Failure, void>> createSuggestion({
    required String authorId,
    required String authorName,
    required String title,
    required String description,
  });

  Future<Either<Failure, void>> toggleUpvote({
    required String suggestionId,
    required String userId,
    required bool isCurrentlyUpvoted,
  });
}
