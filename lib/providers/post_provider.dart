import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _service = PostService();

  Stream<List<PostModel>> getPostsStream({String? categoryId}) {
    return _service.getPostsStream(categoryId: categoryId);
  }

  Stream<List<PostModel>> searchPosts(String query) {
    return _service.searchPosts(query);
  }

  Future<List<PostModel>> getPosts({String? categoryId}) {
    return _service.getPosts(categoryId: categoryId);
  }

  Future<void> toggleLike(String postId, String userId) async {
    await _service.toggleLike(postId, userId);
  }

  Future<String?> uploadImage(Uint8List fileBytes, String fileName) {
    return _service.uploadImage(fileBytes, fileName);
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String categoryId,
    required String userId,
    String? imageUrl,
  }) async {
    await _service.createPost(
      title: title,
      content: content,
      categoryId: categoryId,
      userId: userId,
      imageUrl: imageUrl,
    );
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String content,
    required String categoryId,
    String? imageUrl,
  }) async {
    await _service.updatePost(
      id: id,
      title: title,
      content: content,
      categoryId: categoryId,
      imageUrl: imageUrl,
    );
  }

  Future<void> deletePost(String id) async {
    await _service.deletePost(id);
  }
}
