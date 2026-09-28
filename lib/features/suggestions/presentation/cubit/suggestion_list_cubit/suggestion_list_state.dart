import 'package:equatable/equatable.dart';
import '../../../domain/entities/suggestion_entity.dart';

abstract class SuggestionListState extends Equatable {
  const SuggestionListState();
  @override
  List<Object?> get props => [];
}

class SuggestionListLoading extends SuggestionListState {}

class SuggestionListLoaded extends SuggestionListState {
  final List<SuggestionEntity> suggestions;
  final String currentUserId;
  const SuggestionListLoaded({
    required this.suggestions,
    required this.currentUserId,
  });
  @override
  List<Object?> get props => [suggestions, currentUserId];
}

class SuggestionListError extends SuggestionListState {
  final String message;
  const SuggestionListError(this.message);
  @override
  List<Object?> get props => [message];
}
