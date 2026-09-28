import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/suggestion_repository.dart';

class ToggleUpvoteUseCase {
  final SuggestionRepository repository;
  const ToggleUpvoteUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String suggestionId,
    required String userId,
    required bool isCurrentlyUpvoted,
  }) {
    return repository.toggleUpvote(
      suggestionId: suggestionId,
      userId: userId,
      isCurrentlyUpvoted: isCurrentlyUpvoted,
    );
  }
}
