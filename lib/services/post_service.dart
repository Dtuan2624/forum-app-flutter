import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post_model.dart';

class PostService {
  final _db = FirebaseDatabase.instance.ref();
  final _storage = FirebaseStorage.instance;

  Stream<List<PostModel>> getPostsStream({String? categoryId}) {
    return _db.child('posts').onValue.map((event) {
      final posts = <PostModel>[];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final post = PostModel.fromMap(
              key.toString(),
              Map<String, dynamic>.from(value),
            );
            if (categoryId == null ||
                categoryId.isEmpty ||
                post.categoryId == categoryId) {
              posts.add(post);
            }
          }
        });
      }
      // Sort by creation time descending
      posts.sort(
        (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
          a.createdAt?.millisecondsSinceEpoch ?? 0,
        ),
      );
      return posts;
    });
  }

  Future<List<PostModel>> getPosts({String? categoryId}) async {
    final snapshot = await _db.child('posts').get();
    final posts = <PostModel>[];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final post = PostModel.fromMap(
            key.toString(),
            Map<String, dynamic>.from(value),
          );
          if (categoryId == null ||
              categoryId.isEmpty ||
              post.categoryId == categoryId) {
            posts.add(post);
          }
        }
      });
    }
    // Sort by creation time descending
    posts.sort(
      (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
        a.createdAt?.millisecondsSinceEpoch ?? 0,
      ),
    );
    return posts;
  }

  Stream<List<PostModel>> searchPosts(String query) {
    return _db.child('posts').onValue.map((event) {
      final posts = <PostModel>[];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final post = PostModel.fromMap(
              key.toString(),
              Map<String, dynamic>.from(value),
            );
            posts.add(post);
          }
        });
      }

      if (query.isEmpty) {
        posts.sort(
          (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
            a.createdAt?.millisecondsSinceEpoch ?? 0,
          ),
        );
        return posts;
      }

      return posts.where((post) {
        final titleLower = post.title.toLowerCase();
        final contentLower = post.content.toLowerCase();
        final searchLower = query.toLowerCase();
        return titleLower.contains(searchLower) ||
            contentLower.contains(searchLower);
      }).toList();
    });
  }

  // Hàm Like/Unlike bài viết
  Future<void> toggleLike(String postId, String userId) async {
    final likesRef = _db.child('posts/$postId/likes/$userId');
    final snapshot = await likesRef.get();
    if (snapshot.exists) {
      await likesRef.remove(); // Unlike
    } else {
      await likesRef.set(true); // Like
    }
  }

  Future<String?> uploadImage(Uint8List fileBytes, String fileName) async {
    try {
      final ref = _storage.ref().child('images/$fileName');
      final uploadTask = await ref.putData(fileBytes);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String categoryId,
    required String userId,
    String? imageUrl,
  }) async {
    final newPostRef = _db.child('posts').push();
    await newPostRef.set({
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String content,
    required String categoryId,
    String? imageUrl,
  }) async {
    await _db.child('posts/$id').update({
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
    });
  }

  Future<void> deletePost(String id) async {
    await _db.child('posts/$id').remove();
  }
}
