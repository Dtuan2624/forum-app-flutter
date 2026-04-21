import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post_model.dart';

class PostService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Stream<List<PostModel>> getPostsStream({String? categoryId}) {
    Query<Map<String, dynamic>> query = _db
        .collection('posts')
        .orderBy('createdAt', descending: true);
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<List<PostModel>> getPosts({String? categoryId}) async {
    Query<Map<String, dynamic>> query = _db
        .collection('posts')
        .orderBy('createdAt', descending: true);
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<PostModel>> searchPosts(String query) {
    return _db
        .collection('posts')
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs
              .map((doc) => PostModel.fromMap(doc.id, doc.data()))
              .toList();
          
          if (query.isEmpty) return posts;
          
          return posts.where((post) {
            final titleLower = post.title.toLowerCase();
            final contentLower = post.content.toLowerCase();
            final searchLower = query.toLowerCase();
            return titleLower.contains(searchLower) || contentLower.contains(searchLower);
          }).toList();
        });
  }

  // Hàm Like/Unlike bài viết
  Future<void> toggleLike(String postId, String userId) async {
    final postRef = _db.collection('posts').doc(postId);
    final doc = await postRef.get();
    if (!doc.exists) return;

    final List<String> likes = List<String>.from(doc.data()?['likes'] ?? []);
    if (likes.contains(userId)) {
      likes.remove(userId); // Unlike
    } else {
      likes.add(userId); // Like
    }

    await postRef.update({'likes': likes});
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
    await _db.collection('posts').add({
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'userId': userId,
      'imageUrl': imageUrl,
      'likes': [], // Khởi tạo danh sách like trống
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String content,
    required String categoryId,
    String? imageUrl,
  }) async {
    await _db.collection('posts').doc(id).update({
      'title': title,
      'content': content,
      'categoryId': categoryId,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
  }

  Future<void> deletePost(String id) async {
    await _db.collection('posts').doc(id).delete();
  }
}
