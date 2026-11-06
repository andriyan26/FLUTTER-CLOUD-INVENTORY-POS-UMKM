import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;
  final String selectedVariant;
  final int? _unitPriceOverride;

  const CartItemModel({
    required this.product,
    required this.quantity,
    this.selectedVariant = 'Reguler',
    int? unitPriceOverride,
  }) : _unitPriceOverride = unitPriceOverride;

  int get unitPrice => _unitPriceOverride ?? product.price;
  int get subtotal => unitPrice * quantity;

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    String? selectedVariant,
    int? unitPriceOverride,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      unitPriceOverride: unitPriceOverride ?? _unitPriceOverride,
    );
  }
}
