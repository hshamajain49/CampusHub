import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/suggestion_entity.dart';

class SuggestionModel extends SuggestionEntity {
  const SuggestionModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.title,
    required super.description,
    required super.upvotedBy,
    required super.createdAt,
  });

  factory SuggestionModel.fromJson(String id, Map<String, dynamic> json) {
    return SuggestionModel(
      id: id,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      upvotedBy: List<String>.from(json['upvotedBy'] ?? const []),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
