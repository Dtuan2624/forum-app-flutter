import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';

class CommentProvider extends ChangeNotifier {
  final CommentService _service = CommentService();

  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _service.getCommentsStream(postId);
  }

  Future<void> createComment({
    required String postId,
    required String userId,
    required String text,
    String? parentCommentId,
  }) {
    return _service.createComment(
      postId: postId,
      userId: userId,
      text: text,
      parentCommentId: parentCommentId,
    );
  }

  Future<void> deleteComment(String postId, String commentId) {
    return _service.deleteComment(postId, commentId);
  }
}
