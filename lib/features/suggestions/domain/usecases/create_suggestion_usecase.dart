import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/suggestion_repository.dart';

class CreateSuggestionUseCase {
  final SuggestionRepository repository;
  const CreateSuggestionUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String authorId,
    required String authorName,
    required String title,
    required String description,
  }) {
    return repository.createSuggestion(
      authorId: authorId,
      authorName: authorName,
      title: title,
      description: description,
    );
  }
}
