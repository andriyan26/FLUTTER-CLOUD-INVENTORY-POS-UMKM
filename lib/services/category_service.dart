import '../core/config/supabase_config.dart';
import '../models/category_model.dart';

class CategoryService {
  static final List<CategoryModel> _demoCategories = [
    CategoryModel(
      id: 'cat-1',
      name: 'Minuman & Kopi',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    CategoryModel(
      id: 'cat-2',
      name: 'Roti & Pastry',
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
    CategoryModel(
      id: 'cat-3',
      name: 'Kuliner & Snack',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    CategoryModel(
      id: 'cat-4',
      name: 'Sembako UMKM',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    CategoryModel(
      id: 'cat-5',
      name: 'Kebutuhan Harian',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  /// Thumbnail kategori bergaya ilustrasi/foto bersih seperti di Video 2 (KONSEP SETELAH LOGIN.mp4)
  static String getCategoryThumbnail(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('minum') || lower.contains('kopi')) {
      return 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=300&q=80';
    }
    if (lower.contains('roti') || lower.contains('pastry') || lower.contains('bakery')) {
      return 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80';
    }
    if (lower.contains('kuliner') || lower.contains('snack') || lower.contains('ringan')) {
      return 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=300&q=80';
    }
    if (lower.contains('sembako')) {
      return 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=300&q=80';
    }
    return 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=300&q=80';
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

  Future<CategoryModel> createCategory(String name, {required bool isAdmin}) async {
    if (!isAdmin) {
      throw Exception('Akses ditolak: Hanya Admin yang dapat menambah kategori.');
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
      throw Exception('Akses ditolak: Hanya Admin yang dapat mengubah kategori.');
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
      throw Exception('Akses ditolak: Hanya Admin yang dapat menghapus kategori.');
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
