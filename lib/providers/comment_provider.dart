import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';
import 'package:uuid/uuid.dart';

class CommentProvider extends ChangeNotifier {
  final CommentService _service = CommentService();
  List<CommentModel> _comments = [];
  bool _isLoading = false;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;

  Future<void> fetchComments(String postId) async {
    _isLoading = true;
    notifyListeners();
    _comments = await _service.getComments(postId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    final newComment = CommentModel(
      id: const Uuid().v4(),
      postId: postId,
      userId: userId,
      userName: userName,
      content: content,
      createdAt: DateTime.now(),
    );
    await _service.addComment(newComment);
    await fetchComments(postId);
  }

  Future<void> deleteComment(String commentId, String postId) async {
    await _service.deleteComment(commentId);
    await fetchComments(postId);
  }
}
