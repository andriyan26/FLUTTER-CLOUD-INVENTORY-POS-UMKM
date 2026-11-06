import '../core/constants/app_constants.dart';

class ProductModel {
  final String id;
  final String sku;
  final String name;
  final String categoryId;
  final String categoryName;
  final int price;
  final int stock;
  final String description;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.categoryId,
    this.categoryName = 'Umum',
    required this.price,
    required this.stock,
    required this.description,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  String get primaryImage => images.isNotEmpty
      ? images.first
      : 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80';

  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= AppConstants.lowStockThreshold;

  String get stockStatusLabel {
    if (isOutOfStock) return 'Habis';
    if (isLowStock) return 'Menipis';
    return 'Tersedia';
  }

  ProductModel copyWith({
    String? id,
    String? sku,
    String? name,
    String? categoryId,
    String? categoryName,
    int? price,
    int? stock,
    String? description,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final rawImages = map['images'];
    final List<String> parsedImages = [];
    if (rawImages is List) {
      for (final item in rawImages) {
        if (item != null && item.toString().trim().isNotEmpty) {
          parsedImages.add(item.toString().trim());
        }
      }
    }

    String catName = 'Umum';
    if (map['categories'] is Map) {
      catName = (map['categories']['name'] ?? 'Umum').toString();
    } else if (map['category_name'] != null) {
      catName = map['category_name'].toString();
    }

    return ProductModel(
      id: (map['id'] ?? '').toString(),
      sku: (map['sku'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      categoryId: (map['category_id'] ?? '').toString(),
      categoryName: catName,
      price: int.tryParse((map['price'] ?? 0).toString()) ?? 0,
      stock: int.tryParse((map['stock'] ?? 0).toString()) ?? 0,
      description: (map['description'] ?? '').toString(),
      images: parsedImages,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'name': name,
      'category_id': categoryId,
      'price': price,
      'stock': stock,
      'description': description,
      'images': images,
    };
  }
}
