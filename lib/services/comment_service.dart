import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final _db = FirebaseFirestore.instance;

  Future<List<CommentModel>> getComments(String postId) async {
    final snapshot = await _db
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CommentModel(
        id: doc.id,
        postId: data['postId'],
        userId: data['userId'],
        userName: data['userName'],
        content: data['content'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  Future<void> addComment(CommentModel comment) async {
    await _db.collection('comments').doc(comment.id).set({
      'postId': comment.postId,
      'userId': comment.userId,
      'userName': comment.userName,
      'content': comment.content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteComment(String commentId) async {
    await _db.collection('comments').doc(commentId).delete();
  }
}
