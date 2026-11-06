import '../core/config/supabase_config.dart';
import '../models/category_model.dart';

class CategoryService {
  static final List<CategoryModel> _demoCategories = [
    CategoryModel(
      id: 'cat-1',
      name: 'Minuman',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    CategoryModel(
      id: 'cat-2',
      name: 'Makanan',
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
    CategoryModel(
      id: 'cat-3',
      name: 'Roti',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    CategoryModel(
      id: 'cat-4',
      name: 'Cemilan',
      createdAt: DateTime.now().subtract(const Duration(days: 22)),
    ),
    CategoryModel(
      id: 'cat-5',
      name: 'Sembako',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
    CategoryModel(
      id: 'cat-6',
      name: 'Kebutuhan',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  /// Thumbnail kategori menggunakan foto produk asli dari folder Produk/
  static String getCategoryThumbnail(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('minum') || lower.contains('kopi')) {
      return 'assets/produk/minuman_kopi_susu_gula_aren.jpg';
    }
    if (lower.contains('makan') || lower.contains('kuliner')) {
      return 'assets/produk/makanan_nasi_goreng_spesial.jpg';
    }
    if (lower.contains('roti') ||
        lower.contains('pastry') ||
        lower.contains('bakery')) {
      return 'assets/produk/roti_butter_croissant.jpg';
    }
    if (lower.contains('cemilan') ||
        lower.contains('snack') ||
        lower.contains('ringan')) {
      return 'assets/produk/cemilan_dimsum_mentai.jpg';
    }
    if (lower.contains('sembako')) {
      return 'assets/produk/sembako_beras_premium.jpg';
    }
    return 'assets/produk/kebutuhan_sabun_mandi_cair.jpg';
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final response = await client
          .from('categories')
          .select()
          .order('name', ascending: true);
      return (response as List)
          .map((item) => CategoryModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return List<CategoryModel>.from(_demoCategories);
  }

  Future<CategoryModel> createCategory(
    String name, {
    required bool isAdmin,
  }) async {
    if (!isAdmin) {
      throw Exception(
        'Akses ditolak: Hanya Admin yang dapat menambah kategori.',
      );
    }
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw Exception('Nama kategori tidak boleh kosong.');
    }

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final res = await client
          .from('categories')
          .insert({'name': cleanName})
          .select()
          .single();
      return CategoryModel.fromMap(res);
    }

    final exists = _demoCategories.any(
      (c) => c.name.toLowerCase() == cleanName.toLowerCase(),
    );
    if (exists) {
      throw Exception('Kategori "$cleanName" sudah terdaftar.');
    }
    final created = CategoryModel(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      createdAt: DateTime.now(),
    );
    _demoCategories.add(created);
    return created;
  }

  Future<CategoryModel> updateCategory(
    String id,
    String newName, {
    required bool isAdmin,
  }) async {
    if (!isAdmin) {
      throw Exception(
        'Akses ditolak: Hanya Admin yang dapat mengubah kategori.',
      );
    }
    final cleanName = newName.trim();
    if (cleanName.isEmpty) {
      throw Exception('Nama kategori tidak boleh kosong.');
    }

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final res = await client
          .from('categories')
          .update({'name': cleanName})
          .eq('id', id)
          .select()
          .single();
      return CategoryModel.fromMap(res);
    }

    final index = _demoCategories.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('Kategori tidak ditemukan.');
    }
    final updated = CategoryModel(
      id: id,
      name: cleanName,
      createdAt: _demoCategories[index].createdAt,
    );
    _demoCategories[index] = updated;
    return updated;
  }

  Future<void> deleteCategory(
    String id, {
    required int linkedProductCount,
    required bool isAdmin,
  }) async {
    if (!isAdmin) {
      throw Exception(
        'Akses ditolak: Hanya Admin yang dapat menghapus kategori.',
      );
    }
    if (linkedProductCount > 0) {
      throw Exception(
        'Kategori tidak dapat dihapus karena masih memiliki $linkedProductCount produk aktif. Pindahkan atau hapus produk terlebih dahulu.',
      );
    }

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      await client.from('categories').delete().eq('id', id);
      return;
    }

    _demoCategories.removeWhere((c) => c.id == id);
  }
}
