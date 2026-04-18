import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();
  Stream<List<CategoryModel>> get categoriesStream =>
      _service.getCategoriesStream();

  Future<void> createCategory(String name) async {
    await _service.createCategory(name);
  }

  Future<void> updateCategory(String id, String name) async {
    await _service.updateCategory(id, name);
  }

  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
  }
}
