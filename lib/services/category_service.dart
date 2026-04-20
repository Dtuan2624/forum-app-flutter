import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final _db = FirebaseFirestore.instance;

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _db
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return CategoryModel.fromMap(doc.id, doc.data());
          }).toList(),
        );
  }

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final doc = await _db.collection('categories').doc(id).get();
    if (!doc.exists) return null;
    return CategoryModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> createCategory(String name) async {
    await _db.collection('categories').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory(String id, String name) async {
    await _db.collection('categories').doc(id).update({'name': name});
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }
}
