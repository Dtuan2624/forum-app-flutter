import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';
import 'package:uuid/uuid.dart';class CommentProvider extends ChangeNotifier {
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

  // ĐÃ CẬP NHẬT: Thêm tham số optional parentId và parentUserName
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String content,
    String? parentId,         // null nếu là bình luận gốc, có giá trị nếu là reply
    String? parentUserName,   // (Tùy chọn) Để hiển thị "Trả lời @Nguyễn Văn A"
  }) async {
    final newComment = CommentModel(
      id: const Uuid().v4(),
      postId: postId,
      userId: userId,
      userName: userName,
      content: content,
      parentId: parentId,     // Chèn vào model
      parentUserName: parentUserName, // Chèn vào model
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