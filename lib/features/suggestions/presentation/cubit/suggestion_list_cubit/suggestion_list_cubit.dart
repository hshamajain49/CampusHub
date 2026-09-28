import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/suggestion_entity.dart';
import '../../../domain/usecases/get_suggestions_stream_usecase.dart';
import '../../../domain/usecases/toggle_upvote_usecase.dart';
import 'suggestion_list_state.dart';

class SuggestionListCubit extends Cubit<SuggestionListState> {
  final GetSuggestionsStreamUseCase getSuggestionsStreamUseCase;
  final ToggleUpvoteUseCase toggleUpvoteUseCase;
  final String currentUserId;
  StreamSubscription? _subscription;

  SuggestionListCubit({
    required this.getSuggestionsStreamUseCase,
    required this.toggleUpvoteUseCase,
    required this.currentUserId,
  }) : super(SuggestionListLoading()) {
    _subscribe();
  }

  void _subscribe() {
    _subscription = getSuggestionsStreamUseCase().listen((result) {
      result.fold(
        (failure) => emit(SuggestionListError(failure.message)),
        (suggestions) => emit(
          SuggestionListLoaded(
            suggestions: suggestions,
            currentUserId: currentUserId,
          ),
        ),
      );
    });
  }

  // Fire-and-forget: the Firestore stream above pushes the updated doc back
  // automatically, so we don't manually mutate state here.
  Future<void> toggleUpvote(SuggestionEntity suggestion) async {
    final isUpvoted = suggestion.isUpvotedBy(currentUserId);
    await toggleUpvoteUseCase(
      suggestionId: suggestion.id,
      userId: currentUserId,
      isCurrentlyUpvoted: isUpvoted,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
