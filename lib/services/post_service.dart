import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import 'upload_service.dart';

class PostService {
  final _db = FirebaseFirestore.instance;
  final _uploadService = UploadService();

  // Real-time Stream of posts
  Stream<List<PostModel>> getPostsStream({String? categoryId}) {
    Query query = _db.collection('posts').orderBy('createdAt', descending: true);
    
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PostModel(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          categoryId: data['categoryId'] ?? '',
          userId: data['userId'] ?? '',
          imageUrl: data['imageUrl'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  // One-time fetch of posts
  Future<List<PostModel>> fetchPosts({String? categoryId}) async {
    Query query = _db.collection('posts').orderBy('createdAt', descending: true);
    
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return PostModel(
        id: doc.id,
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        categoryId: data['categoryId'] ?? '',
        userId: data['userId'] ?? '',
        imageUrl: data['imageUrl'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
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

    await _db.collection('posts').add({
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
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

    Map<String, dynamic> data = {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
    };
    if (categoryId != null) data['categoryId'] = categoryId;

    await _db.collection('posts').doc(postId).update(data);
  }

  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }
}
