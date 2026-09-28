import 'package:equatable/equatable.dart';

class SuggestionEntity extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final List<String> upvotedBy;
  final DateTime createdAt;

  const SuggestionEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.upvotedBy,
    required this.createdAt,
  });

  int get upvoteCount => upvotedBy.length;
  bool isUpvotedBy(String userId) => upvotedBy.contains(userId);

  @override
  List<Object?> get props => [
    id,
    authorId,
    authorName,
    title,
    description,
    upvotedBy,
    createdAt,
  ];
}
