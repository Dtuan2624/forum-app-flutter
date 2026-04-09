class PostModel {
  final String id;
  final String title;
  final String content;
  final String categoryId;
  final String userId;
  final String? imageUrl;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.userId,
    this.imageUrl,
    required this.createdAt,
  });

  PostModel copyWith({
    String? title,
    String? content,
    String? categoryId,
    String? imageUrl,
  }) {
    return PostModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      userId: userId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
    );
  }
}
