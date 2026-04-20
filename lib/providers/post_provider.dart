import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _service = PostService();

  Stream<List<PostModel>> getPostsStream({String? categoryId}) {
    return _service.getPostsStream(categoryId: categoryId);
  }

  Future<List<PostModel>> getPosts({String? categoryId}) {
    return _service.getPosts(categoryId: categoryId);
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String categoryId,
    required String userId,
  }) async {
    await _service.createPost(
      title: title,
      content: content,
      categoryId: categoryId,
      userId: userId,
    );
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String content,
    required String categoryId,
  }) async {
    await _service.updatePost(
      id: id,
      title: title,
      content: content,
      categoryId: categoryId,
    );
  }

  Future<void> deletePost(String id) async {
    await _service.deletePost(id);
  }
}
