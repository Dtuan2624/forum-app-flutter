import 'package:firebase_database/firebase_database.dart';
import '../models/comment_model.dart';

class CommentService {
  final _db = FirebaseDatabase.instance.ref();

  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _db.child('posts/$postId/comments').onValue.map((event) {
      final comments = <CommentModel>[];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final comment = CommentModel.fromMap(
              key.toString(),
              postId,
              Map<String, dynamic>.from(value),
            );
            comments.add(comment);
          }
        });
      }
      // Sort by creation time ascending
      comments.sort(
        (a, b) => (a.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
          b.createdAt?.millisecondsSinceEpoch ?? 0,
        ),
      );
      return comments;
    });
  }

  Future<void> createComment({
    required String postId,
    required String userId,
    required String text,
    String? parentCommentId,
  }) async {
    final newCommentRef = _db.child('posts/$postId/comments').push();
    await newCommentRef.set({
      'userId': userId,
      'text': text,
      'parentCommentId': parentCommentId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _db.child('posts/$postId/comments/$commentId').remove();
  }
}
