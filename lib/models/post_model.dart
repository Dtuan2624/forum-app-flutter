import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String content;
  final String categoryId;
  final String userId;
  final String? imageUrl;
  final List<String> likes; // Danh sách ID người dùng đã like
  final DateTime? createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.userId,
    this.imageUrl,
    this.likes = const [],
    this.createdAt,
  });

  factory PostModel.fromMap(String id, Map<String, dynamic> data) {
    final createdAtValue = data['createdAt'];
    DateTime? createdAt;
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else if (createdAtValue is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtValue);
    }
    
    return PostModel(
      id: id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      likes: List<String>.from(data['likes'] ?? []),
      createdAt: createdAt,
    );
  }
}
