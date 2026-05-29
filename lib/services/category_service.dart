import 'package:firebase_database/firebase_database.dart';
import '../models/category_model.dart';

class CategoryService {
  final _db = FirebaseDatabase.instance.ref();

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _db.child('categories').onValue.map((event) {
      final categories = <CategoryModel>[];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final category = CategoryModel.fromMap(
              key.toString(),
              Map<String, dynamic>.from(value),
            );
            categories.add(category);
          }
        });
      }
      // Sort by creation time descending
      categories.sort(
        (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
          a.createdAt?.millisecondsSinceEpoch ?? 0,
        ),
      );
      return categories;
    });
  }

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db.child('categories').get();
    final categories = <CategoryModel>[];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final category = CategoryModel.fromMap(
            key.toString(),
            Map<String, dynamic>.from(value),
          );
          categories.add(category);
        }
      });
    }
    // Sort by creation time descending
    categories.sort(
      (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
        a.createdAt?.millisecondsSinceEpoch ?? 0,
      ),
    );
    return categories;
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final snapshot = await _db.child('categories/$id').get();
    if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
      return CategoryModel.fromMap(
        id,
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    }
    return null;
  }

  Future<void> createCategory(String name) async {
    try {
      final newCategoryRef = _db.child('categories').push();
      await newCategoryRef.set({
        'name': name,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Create category error: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(String id, String name) async {
    await _db.child('categories/$id').update({'name': name});
  }

  Future<void> deleteCategory(String id) async {
    await _db.child('categories/$id').remove();
  }
}
