import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _categories = await _categoryService.fetchCategories();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(String name, {required bool isAdmin}) async {
    try {
      final created = await _categoryService.createCategory(
        name,
        isAdmin: isAdmin,
      );
      _categories = [..._categories, created];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> editCategory(
    String id,
    String newName, {
    required bool isAdmin,
  }) async {
    try {
      final updated = await _categoryService.updateCategory(
        id,
        newName,
        isAdmin: isAdmin,
      );
      final idx = _categories.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _categories[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeCategory(
    String id, {
    required int linkedProductCount,
    required bool isAdmin,
  }) async {
    try {
      await _categoryService.deleteCategory(
        id,
        linkedProductCount: linkedProductCount,
        isAdmin: isAdmin,
      );
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}

