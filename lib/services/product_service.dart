import '../core/config/supabase_config.dart';
import '../models/product_model.dart';

class ProductService {
  static final List<ProductModel> _demoProducts = [
    ProductModel(
      id: 'prod-1',
      sku: 'UMKM-001',
      name: 'Kopi Susu Gula Aren',
      categoryId: 'cat-1',
      categoryName: 'Minuman & Kopi',
      price: 18000,
      stock: 45,
      description:
          'Kopi susu gula aren khas UMKM dengan racikan espresso robusta pilihan dan susu segar creamy.',
      images: const [
        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-2',
      sku: 'UMKM-002',
      name: 'Cappuccino Creamy',
      categoryId: 'cat-1',
      categoryName: 'Minuman & Kopi',
      price: 22000,
      stock: 38,
      description:
          'Rich espresso mixed with smooth steamed milk and deep chocolate notes.',
      images: const [
        'https://images.unsplash.com/photo-1572442388796-11668a67e53d?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-3',
      sku: 'UMKM-003',
      name: 'Roti Cokelat Croissant',
      categoryId: 'cat-2',
      categoryName: 'Roti & Pastry',
      price: 15000,
      stock: 28,
      description:
          'Roti croissant mentega renyah berlapis dengan isian cokelat lumer premium yang dipanggang setiap pagi.',
      images: const [
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-4',
      sku: 'UMKM-004',
      name: 'Keripik Pisang Lumer',
      categoryId: 'cat-3',
      categoryName: 'Kuliner & Snack',
      price: 14000,
      stock: 42,
      description:
          'Keripik pisang kepok pilihan ekstra renyah dengan balutan cokelat dan susu manis gurih.',
      images: const [
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-5',
      sku: 'UMKM-005',
      name: 'Teh Botol Melati',
      categoryId: 'cat-1',
      categoryName: 'Minuman & Kopi',
      price: 7000,
      stock: 64,
      description:
          'Minuman es teh melati asli dalam kemasan siap minum yang menyegarkan.',
      images: const [
        'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-6',
      sku: 'UMKM-006',
      name: 'Makaroni Pedas Jeruk',
      categoryId: 'cat-3',
      categoryName: 'Kuliner & Snack',
      price: 10000,
      stock: 7,
      description:
          'Makaroni goreng ekstra renyah dengan taburan bumbu cabai daun jeruk level pedas gurih.',
      images: const [
        'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 60)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-7',
      sku: 'UMKM-007',
      name: 'Air Mineral Segar',
      categoryId: 'cat-1',
      categoryName: 'Minuman & Kopi',
      price: 5000,
      stock: 120,
      description:
          'Air mineral pegunungan segar kemasan botol 600ml dingin maupun suhu ruang.',
      images: const [
        'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 70)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-8',
      sku: 'UMKM-008',
      name: 'Mi Instan Spesial',
      categoryId: 'cat-4',
      categoryName: 'Sembako UMKM',
      price: 4500,
      stock: 95,
      description:
          'Mi instan goreng favorit dengan bumbu rempah lengkap siap saji dalam 3 menit.',
      images: const [
        'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 80)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-9',
      sku: 'UMKM-009',
      name: 'Beras Pulen 5 Kg',
      categoryId: 'cat-4',
      categoryName: 'Sembako UMKM',
      price: 72000,
      stock: 6,
      description:
          'Beras putih pulen kualitas super tanpa pemutih kemasan karung praktis 5 Kg.',
      images: const [
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 90)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-10',
      sku: 'UMKM-010',
      name: 'Gula Pasir Murni 1 Kg',
      categoryId: 'cat-4',
      categoryName: 'Sembako UMKM',
      price: 17500,
      stock: 8,
      description:
          'Gula pasir kristal putih murni 1 Kg dari tebu pilihan untuk minuman dan kebutuhan dapur.',
      images: const [
        'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 100)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-11',
      sku: 'UMKM-011',
      name: 'Sabun Cair Antibakteri',
      categoryId: 'cat-5',
      categoryName: 'Kebutuhan Harian',
      price: 16500,
      stock: 50,
      description:
          'Sabun cair organik lembut dengan ekstrak alami untuk kebutuhan kebersihan keluarga.',
      images: const [
        'https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 110)),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<ProductModel> get demoProductsRef => _demoProducts;

  Future<List<ProductModel>> fetchProducts() async {
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final response = await client
          .from('products')
          .select('*, categories(name)')
          .order('created_at', ascending: false);
      return (response as List)
          .map((item) => ProductModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return List<ProductModel>.from(_demoProducts);
  }

  Future<ProductModel> createProduct(
    ProductModel product, {
    required bool isAdmin,
  }) async {
    if (!isAdmin) {
      throw Exception('Akses ditolak: Hanya Admin yang dapat menambah produk.');
    }
    if (product.name.trim().isEmpty) {
      throw Exception('Nama produk tidak boleh kosong.');
    }
    if (product.price < 0 || product.stock < 0) {
      throw Exception('Harga dan stok tidak boleh bernilai negatif.');
    }

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final res = await client
          .from('products')
          .insert(product.toMap())
          .select('*, categories(name)')
          .single();
      return ProductModel.fromMap(res);
    }

    final duplicateSku = _demoProducts.any(
      (p) => p.sku.toLowerCase() == product.sku.trim().toLowerCase(),
    );
    if (duplicateSku) {
      throw Exception('SKU "${product.sku}" sudah digunakan produk lain.');
    }

    final created = product.copyWith(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _demoProducts.insert(0, created);
    return created;
  }

  Future<ProductModel> updateProduct(
    ProductModel product, {
    required bool isAdmin,
  }) async {
    if (!isAdmin) {
      throw Exception('Akses ditolak: Hanya Admin yang dapat mengubah produk.');
    }
    if (product.name.trim().isEmpty) {
      throw Exception('Nama produk tidak boleh kosong.');
    }
    if (product.price < 0 || product.stock < 0) {
      throw Exception('Harga dan stok tidak boleh bernilai negatif.');
    }

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final res = await client
          .from('products')
          .update(product.toMap())
          .eq('id', product.id)
          .select('*, categories(name)')
          .single();
      return ProductModel.fromMap(res);
    }

    final duplicateSku = _demoProducts.any(
      (p) =>
          p.id != product.id &&
          p.sku.toLowerCase() == product.sku.trim().toLowerCase(),
    );
    if (duplicateSku) {
      throw Exception('SKU "${product.sku}" sudah digunakan produk lain.');
    }

    final idx = _demoProducts.indexWhere((p) => p.id == product.id);
    if (idx == -1) {
      throw Exception('Produk tidak ditemukan.');
    }
    final updated = product.copyWith(updatedAt: DateTime.now());
    _demoProducts[idx] = updated;
    return updated;
  }

  Future<void> deleteProduct(String id, {required bool isAdmin}) async {
    if (!isAdmin) {
      throw Exception('Akses ditolak: Hanya Admin yang dapat menghapus produk.');
    }
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      await client.from('products').delete().eq('id', id);
      return;
    }
    _demoProducts.removeWhere((p) => p.id == id);
  }
}
