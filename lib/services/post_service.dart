import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final _db = FirebaseFirestore.instance;

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

  Future<void> createPost({
    required String title,
    required String content,
    required String categoryId,
    required String userId,
  }) async {
    await _db.collection('posts').add({
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String content,
    required String categoryId,
  }) async {
    await _db.collection('posts').doc(id).update({
      'title': title,
      'content': content,
      'categoryId': categoryId,
    });
  }

  Future<void> deletePost(String id) async {
    await _db.collection('posts').doc(id).delete();
  }
}
