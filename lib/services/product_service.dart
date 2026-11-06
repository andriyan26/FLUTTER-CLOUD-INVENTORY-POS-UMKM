import '../core/config/supabase_config.dart';
import '../models/product_model.dart';

class ProductService {
  static final List<ProductModel> _demoProducts = [
    ProductModel(
      id: 'prod-1',
      sku: 'UMKM-001',
      name: 'Kopi Susu',
      categoryId: 'cat-1',
      categoryName: 'Minuman Kopi & Teh',
      price: 18000,
      stock: 45,
      description:
          'Kopi susu gula aren khas UMKM dengan racikan espresso robusta pilihan dan susu segar creamy.',
      images: const [
        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-2',
      sku: 'UMKM-002',
      name: 'Keripik Pisang',
      categoryId: 'cat-2',
      categoryName: 'Makanan Ringan',
      price: 15000,
      stock: 38,
      description:
          'Keripik pisang kepok renyah dengan balutan bumbu manis gurih khas produksi UMKM lokal.',
      images: const [
        'https://images.unsplash.com/photo-1621447504864-d8686e12698c?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-3',
      sku: 'UMKM-003',
      name: 'Roti Cokelat',
      categoryId: 'cat-3',
      categoryName: 'Roti & Bakery',
      price: 12000,
      stock: 25,
      description:
          'Roti lembut panggang setiap pagi dengan isian cokelat lumer premium yang kaya rasa.',
      images: const [
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-4',
      sku: 'UMKM-004',
      name: 'Air Mineral',
      categoryId: 'cat-1',
      categoryName: 'Minuman Kopi & Teh',
      price: 5000,
      stock: 120,
      description:
          'Air mineral pegunungan segar kemasan botol 600ml dingin maupun suhu ruang.',
      images: const [
        'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-5',
      sku: 'UMKM-005',
      name: 'Teh Botol',
      categoryId: 'cat-1',
      categoryName: 'Minuman Kopi & Teh',
      price: 7000,
      stock: 64,
      description:
          'Minuman teh melati asli dalam kemasan siap minum yang menyegarkan.',
      images: const [
        'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-6',
      sku: 'UMKM-006',
      name: 'Makaroni Pedas',
      categoryId: 'cat-2',
      categoryName: 'Makanan Ringan',
      price: 10000,
      stock: 7,
      description:
          'Makaroni goreng ekstra renyah dengan taburan bumbu cabai daun jeruk level pedas gurih.',
      images: const [
        'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-7',
      sku: 'UMKM-007',
      name: 'Sabun',
      categoryId: 'cat-5',
      categoryName: 'Kebutuhan Rumah',
      price: 6500,
      stock: 50,
      description:
          'Sabun mandi antibakteri lembut untuk kebutuhan harian keluarga Indonesia.',
      images: const [
        'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-8',
      sku: 'UMKM-008',
      name: 'Mi Instan',
      categoryId: 'cat-4',
      categoryName: 'Sembako Harian',
      price: 4000,
      stock: 95,
      description:
          'Mi instan goreng favorit dengan bumbu lengkap siap saji dalam 3 menit.',
      images: const [
        'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-9',
      sku: 'UMKM-009',
      name: 'Beras',
      categoryId: 'cat-4',
      categoryName: 'Sembako Harian',
      price: 72000,
      stock: 6,
      description:
          'Beras putih pulen kualitas super tanpa pemutih kemasan karung praktis 5 Kg.',
      images: const [
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-10',
      sku: 'UMKM-010',
      name: 'Gula Pasir',
      categoryId: 'cat-4',
      categoryName: 'Sembako Harian',
      price: 17500,
      stock: 8,
      description:
          'Gula pasir kristal putih murni 1 Kg dari tebu pilihan untuk minuman dan masakan.',
      images: const [
        'https://images.unsplash.com/photo-1581441363689-1f3c3c414635?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
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
