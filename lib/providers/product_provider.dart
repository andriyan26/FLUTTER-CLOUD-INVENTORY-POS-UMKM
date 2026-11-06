import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

enum ProductSortOption {
  newest,
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
}

enum StockFilterOption {
  all,
  available,
  lowStock,
  outOfStock,
}

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastCreatedProductId;
  int _catalogVersion = 0;

  String _searchQuery = '';
  String _selectedCategoryId = 'all';
  StockFilterOption _stockFilter = StockFilterOption.all;
  ProductSortOption _sortOption = ProductSortOption.newest;

  List<ProductModel> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get lastCreatedProductId => _lastCreatedProductId;
  int get catalogVersion => _catalogVersion;
  String get searchQuery => _searchQuery;
  String get selectedCategoryId => _selectedCategoryId;
  StockFilterOption get stockFilter => _stockFilter;
  ProductSortOption get sortOption => _sortOption;

  int get totalProductsCount => _products.length;
  int get totalStockUnits =>
      _products.fold<int>(0, (sum, item) => sum + item.stock);
  List<ProductModel> get lowStockProducts =>
      _products.where((p) => p.stock <= 10).toList();

  List<ProductModel> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    final list = _products.where((product) {
      if (_selectedCategoryId != 'all' &&
          product.categoryId != _selectedCategoryId) {
        return false;
      }

      if (_stockFilter == StockFilterOption.available && product.stock <= 0) {
        return false;
      }
      if (_stockFilter == StockFilterOption.lowStock && !product.isLowStock) {
        return false;
      }
      if (_stockFilter == StockFilterOption.outOfStock &&
          !product.isOutOfStock) {
        return false;
      }

      if (query.isNotEmpty) {
        final matchName = product.name.toLowerCase().contains(query);
        final matchSku = product.sku.toLowerCase().contains(query);
        final matchCat = product.categoryName.toLowerCase().contains(query);
        return matchName || matchSku || matchCat;
      }

      return true;
    }).toList();

    switch (_sortOption) {
      case ProductSortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSortOption.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProductSortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return list;
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _products = await _productService.fetchProducts();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setStockFilter(StockFilterOption filter) {
    if (_stockFilter == filter) return;
    _stockFilter = filter;
    notifyListeners();
  }

  void setSortOption(ProductSortOption sort) {
    if (_sortOption == sort) return;
    _sortOption = sort;
    notifyListeners();
  }

  int countProductsByCategory(String categoryId) {
    return _products.where((p) => p.categoryId == categoryId).length;
  }

  Future<bool> addProduct(
    ProductModel product, {
    bool isAdmin = true,
  }) async {
    try {
      final created = await _productService.createProduct(
        product,
        isAdmin: true,
      );
      _products = [created, ..._products];
      // Reset filter otomatis agar barang baru langsung tampil di urutan #1 paling atas
      _selectedCategoryId = 'all';
      _stockFilter = StockFilterOption.all;
      _searchQuery = '';
      _sortOption = ProductSortOption.newest;
      _lastCreatedProductId = created.id;
      _catalogVersion++;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(
    ProductModel product, {
    bool isAdmin = true,
  }) async {
    try {
      final updated = await _productService.updateProduct(
        product,
        isAdmin: true,
      );
      final idx = _products.indexWhere((p) => p.id == product.id);
      if (idx != -1) {
        _products[idx] = updated;
        _catalogVersion++;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id, {bool isAdmin = true}) async {
    try {
      await _productService.deleteProduct(id, isAdmin: true);
      _products.removeWhere((p) => p.id == id);
      _catalogVersion++;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
