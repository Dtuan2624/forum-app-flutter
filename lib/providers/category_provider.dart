import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();
  List<CategoryModel> categories = [];
  bool isLoading = false;

  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();
    categories = await _service.getCategories();
    isLoading = false;
    notifyListeners();
  }

  Future<void> createCategory(String name) async {
    await _service.createCategory(name);
    await fetchCategories();
  }

  Future<void> updateCategory(String id, String name) async {
    await _service.updateCategory(id, name);
    await fetchCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
    await fetchCategories();
  }
}
