import 'package:hive_flutter/hive_flutter.dart';
import '../models/post_model.dart';
import 'upload_service.dart';

class PostService {
  final _box = Hive.box('posts');
  final _uploadService = UploadService();

  Future<List<PostModel>> fetchPosts({String? categoryId}) async {
    final List<PostModel> posts = _box.values.map((item) {
      return PostModel(
        id: item['id'],
        title: item['title'],
        content: item['content'],
        categoryId: item['categoryId'],
        userId: item['userId'],
        imageUrl: item['imageUrl'],
        createdAt: DateTime.parse(item['createdAt']),
      );
    }).toList();

    if (categoryId != null) {
      return posts.where((p) => p.categoryId == categoryId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return posts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String categoryId,
    required String userId,
    dynamic image,
  }) async {
    String? imageUrl;
    if (image != null) {
      imageUrl = await _uploadService.upload(image);
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, {
      'id': id,
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    String? categoryId,
    dynamic image,
    String? existingImageUrl,
  }) async {
    String? imageUrl = existingImageUrl;
    if (image != null) {
      imageUrl = await _uploadService.upload(image);
    }

    final postData = _box.get(postId);
    if (postData != null) {
      postData['title'] = title;
      postData['content'] = content;
      postData['imageUrl'] = imageUrl;
      if (categoryId != null) postData['categoryId'] = categoryId;
      
      await _box.put(postId, postData);
    }
  }

  Future<void> deletePost(String postId) async {
    await _box.delete(postId);
  }
}
