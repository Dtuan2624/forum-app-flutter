import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';

class CategoryService {
  final _box = Hive.box('categories');

  Future<List<CategoryModel>> getCategories() async {
    final List<CategoryModel> list = _box.values.map((item) {
      return CategoryModel(
        id: item['id'],
        name: item['name'],
      );
    }).toList();

    if (list.isEmpty) {
      // Initialize with defaults if empty
      await createCategory('General');
      await createCategory('Technology');
      await createCategory('Lifestyle');
      return getCategories();
    }

    return list;
  }

  Future<void> createCategory(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, {
      'id': id,
      'name': name,
    });
  }

  Future<void> updateCategory(String id, String name) async {
    await _box.put(id, {
      'id': id,
      'name': name,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }
}
