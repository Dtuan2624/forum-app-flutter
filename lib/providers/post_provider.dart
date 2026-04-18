import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../models/post_model.dart';

class PostProvider extends ChangeNotifier {
  final PostService _service = PostService();

  List<PostModel> posts = [];
  String? categoryId;
  bool loading = false;

  Future<void> load({bool refresh = false}) async {
    try {
      loading = true;
      if (refresh) notifyListeners();

      posts = await _service.fetchPosts(categoryId: categoryId);
    } catch (e) {
      debugPrint("PostProvider load error: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String categoryId,
    required String userId,
    dynamic image,
  }) async {
    await _service.createPost(
      title: title,
      content: content,
      categoryId: categoryId,
      userId: userId,
      image: image,
    );
    await load();
  }

  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    String? categoryId,
    dynamic image,
    String? existingImageUrl,
  }) async {
    await _service.updatePost(
      postId: postId,
      title: title,
      content: content,
      categoryId: categoryId,
      image: image,
      existingImageUrl: existingImageUrl,
    );
    await load();
  }

  Future<void> deletePost(String postId) async {
    await _service.deletePost(postId);
    await load();
  }

  void changeCategory(String? id) {
    categoryId = id;
    load();
  }
}
