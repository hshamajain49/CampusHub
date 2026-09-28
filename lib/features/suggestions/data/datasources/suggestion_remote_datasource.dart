import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/suggestion_model.dart';

abstract class SuggestionRemoteDataSource {
  Stream<List<SuggestionModel>> getSuggestionsStream();

  Future<void> createSuggestion({
    required String authorId,
    required String authorName,
    required String title,
    required String description,
  });

  Future<void> toggleUpvote({
    required String suggestionId,
    required String userId,
    required bool isCurrentlyUpvoted,
  });
}

class SuggestionRemoteDataSourceImpl implements SuggestionRemoteDataSource {
  final FirebaseFirestore firestore;
  SuggestionRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<SuggestionModel>> getSuggestionsStream() {
    return firestore
        .collection('suggestions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => SuggestionModel.fromJson(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> createSuggestion({
    required String authorId,
    required String authorName,
    required String title,
    required String description,
  }) async {
    try {
      await firestore.collection('suggestions').add({
        'authorId': authorId,
        'authorName': authorName,
        'title': title,
        'description': description,
        'upvotedBy': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw const ServerException(
        'Failed to submit suggestion. Please try again.',
      );
    }
  }

  @override
  Future<void> toggleUpvote({
    required String suggestionId,
    required String userId,
    required bool isCurrentlyUpvoted,
  }) async {
    try {
      await firestore.collection('suggestions').doc(suggestionId).update({
        'upvotedBy': isCurrentlyUpvoted
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw const ServerException(
        'Failed to update your vote. Please try again.',
      );
    }
  }
}
