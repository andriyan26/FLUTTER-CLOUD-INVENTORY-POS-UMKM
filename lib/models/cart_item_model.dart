import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;
  final String selectedVariant;
  final int unitPriceOverride;

  const CartItemModel({
    required this.product,
    required this.quantity,
    this.selectedVariant = 'Reguler',
    int? unitPriceOverride,
  }) : unitPriceOverride = unitPriceOverride ?? product.price;

  int get unitPrice => unitPriceOverride;
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
      unitPriceOverride: unitPriceOverride ?? this.unitPriceOverride,
    );
  }
}
