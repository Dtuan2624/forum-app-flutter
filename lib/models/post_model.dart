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
    if (createdAtValue is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtValue);
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    }

    // Convert likes from Map to List
    List<String> likes = [];
    if (data['likes'] is Map) {
      likes = (data['likes'] as Map).keys.cast<String>().toList();
    } else if (data['likes'] is List) {
      likes = List<String>.from(data['likes'] ?? []);
    }

    return PostModel(
      id: id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      likes: likes,
      createdAt: createdAt,
    );
  }
}
