import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final String? parentCommentId;
  final DateTime? createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    this.parentCommentId,
    this.createdAt,
  });

  factory CommentModel.fromMap(
    String id,
    String postId,
    Map<String, dynamic> data,
  ) {
    final rawCreatedAt = data['createdAt'];
    DateTime? createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else if (rawCreatedAt is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    }

    return CommentModel(
      id: id,
      postId: postId,
      userId: data['userId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      parentCommentId: data['parentCommentId'] as String?,
      createdAt: createdAt,
    );
  }
}
