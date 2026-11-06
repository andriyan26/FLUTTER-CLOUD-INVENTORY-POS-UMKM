import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  int get totalItemsCount =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  int get subtotal =>
      _items.fold<int>(0, (sum, item) => sum + item.subtotal);

  int get total => subtotal;

  /// Menambahkan produk ke keranjang kasir dengan validasi stok ketat
  String? addToCart(
    ProductModel product, {
    int quantity = 1,
    String variant = 'Reguler',
    int? unitPriceOverride,
  }) {
    if (product.stock <= 0) {
      return 'Stok "${product.name}" sedang habis.';
    }

    final existingIdx = _items.indexWhere(
      (item) =>
          item.product.id == product.id && item.selectedVariant == variant,
    );

    final totalProductQtyInCart = _items
        .where((item) => item.product.id == product.id)
        .fold<int>(0, (sum, item) => sum + item.quantity);

    if (totalProductQtyInCart + quantity > product.stock) {
      return 'Stok "${product.name}" hanya tersisa ${product.stock} unit.';
    }

    if (existingIdx != -1) {
      final current = _items[existingIdx];
      _items[existingIdx] = current.copyWith(
        quantity: current.quantity + quantity,
        product: product,
      );
    } else {
      _items.add(
        CartItemModel(
          product: product,
          quantity: quantity,
          selectedVariant: variant,
          unitPriceOverride: unitPriceOverride,
        ),
      );
    }
    notifyListeners();
    return null;
  }

  String? incrementQuantity(int index) {
    if (index < 0 || index >= _items.length) return null;
    final item = _items[index];

    final totalProductQtyInCart = _items
        .where((e) => e.product.id == item.product.id)
        .fold<int>(0, (sum, e) => sum + e.quantity);

    if (totalProductQtyInCart + 1 > item.product.stock) {
      return 'Stok maksimal "${item.product.name}" (${item.product.stock}) telah tercapai.';
    }

    _items[index] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
    return null;
  }

  void decrementQuantity(int index) {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    if (item.quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = item.copyWith(quantity: item.quantity - 1);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

