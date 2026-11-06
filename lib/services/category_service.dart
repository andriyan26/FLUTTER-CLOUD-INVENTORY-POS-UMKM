import '../core/config/supabase_config.dart';
import '../models/category_model.dart';

class CategoryService {
  static final List<CategoryModel> _demoCategories = [
    CategoryModel(
      id: 'cat-1',
      name: 'Minuman Kopi & Teh',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    CategoryModel(
      id: 'cat-2',
      name: 'Makanan Ringan',
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
    CategoryModel(
      id: 'cat-3',
      name: 'Roti & Bakery',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    CategoryModel(
      id: 'cat-4',
      name: 'Sembako Harian',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    CategoryModel(
      id: 'cat-5',
      name: 'Kebutuhan Rumah',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

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
