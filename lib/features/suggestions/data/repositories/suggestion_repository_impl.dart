import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/suggestion_entity.dart';
import '../../domain/repositories/suggestion_repository.dart';
import '../datasources/suggestion_remote_datasource.dart';

class SuggestionRepositoryImpl implements SuggestionRepository {
  final SuggestionRemoteDataSource remoteDataSource;
  const SuggestionRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, List<SuggestionEntity>>>
  getSuggestionsStream() async* {
    try {
      yield* remoteDataSource
          .getSuggestionsStream()
          .map<Either<Failure, List<SuggestionEntity>>>(
            (models) => Right(models),
          );
    } catch (e) {
      yield const Left(ServerFailure('Failed to load suggestions.'));
    }
  }

  @override
  Future<Either<Failure, void>> createSuggestion({
    required String authorId,
    required String authorName,
    required String title,
    required String description,
  }) async {
    try {
      await remoteDataSource.createSuggestion(
        authorId: authorId,
        authorName: authorName,
        title: title,
        description: description,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleUpvote({
    required String suggestionId,
    required String userId,
    required bool isCurrentlyUpvoted,
  }) async {
    try {
      await remoteDataSource.toggleUpvote(
        suggestionId: suggestionId,
        userId: userId,
        isCurrentlyUpvoted: isCurrentlyUpvoted,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
