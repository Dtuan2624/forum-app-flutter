import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final _db = FirebaseFirestore.instance;

  Stream<List<CategoryModel>> getCategoriesStream() {
    // Your screenshot showed 'categories' and 'topics'. 
    // Using 'categories' as shown in the middle panel of your screenshot.
    return _db.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel(
          id: doc.id,
          name: doc['name'] ?? '',
        );
      }).toList();
    });
  }

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db.collection('categories').get();
    return snapshot.docs.map((doc) {
      return CategoryModel(
        id: doc.id,
        name: doc['name'] ?? '',
      );
    }).toList();
  }

  Future<void> createCategory(String name) async {
    await _db.collection('categories').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory(String id, String name) async {
    await _db.collection('categories').doc(id).update({
      'name': name,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }
}
