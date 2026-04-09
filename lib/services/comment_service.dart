import 'package:hive_flutter/hive_flutter.dart';
import '../models/comment_model.dart';

class CommentService {
  final _box = Hive.box('comments');

  Future<List<CommentModel>> getComments(String postId) async {
    final List<CommentModel> list = _box.values.map((item) {
      return CommentModel.fromMap(Map<String, dynamic>.from(item));
    }).toList();

    return list
        .where((c) => c.postId == postId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addComment(CommentModel comment) async {
    await _box.put(comment.id, comment.toMap());
  }

  Future<void> deleteComment(String commentId) async {
    await _box.delete(commentId);
  }
}
