class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'],
      postId: map['postId'],
      userId: map['userId'],
      userName: map['userName'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
