import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../models/user_profile.dart';
import 'product_service.dart';

/// Service Database Lokal Terintegrasi & Permanen
/// Menyimpan data Pengguna, Produk, Kategori, dan Transaksi ke penyimpanan lokal (LocalStorage/SharedPreferences)
/// sehingga data TIDAK HILANG saat di-refresh atau dibuka kembali di iPhone maupun browser,
/// serta memvalidasi login secara KETAT (jika akun atau password salah, login DITOLAK!).
class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  static const String _keyAccounts = 'cloud_pos_accounts_v2';
  static const String _keyActiveSession = 'cloud_pos_active_session_v2';
  static const String _keyProducts = 'cloud_pos_products_v2';
  static const String _keyCategories = 'cloud_pos_categories_v2';
  static const String _keyTransactions = 'cloud_pos_transactions_v2';
  static const String _keyCustomSupabaseUrl = 'cloud_pos_custom_supabase_url';
  static const String _keyCustomSupabaseKey = 'cloud_pos_custom_supabase_key';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ===========================================================================
  // 1. MANAJEMEN AKUN & AUTENTIKASI KETAT
  // ===========================================================================

  /// Akun bawaan sistem awal (Admin & Kasir)
  static final List<Map<String, dynamic>> _defaultAccounts = [
    {
      'id': 'cloud-admin-001',
      'email': 'dailyflutterui@gmail.com',
      'username': 'andriyan',
      'password': '123456',
      'full_name': 'Andriyan (Admin UMKM)',
      'role': 'admin',
      'avatar_url':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      'phone_number': '+62 812-8899-2026',
      'store_name': 'CloudPOS • Cabang Utama UMKM',
      'store_address': 'Jl. Asia Afrika No. 88, Kota Bandung',
      'bio': 'Founder & Senior Store Manager CloudPOS UMKM',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'cloud-admin-002',
      'email': 'admin@umkm.id',
      'username': 'admin',
      'password': '123456',
      'full_name': 'Admin Toko UMKM',
      'role': 'admin',
      'avatar_url':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      'phone_number': '+62 812-8899-2026',
      'store_name': 'CloudPOS • Cabang Utama UMKM',
      'store_address': 'Jl. Asia Afrika No. 88, Kota Bandung',
      'bio': 'Administrator Sistem & Gudang',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'cloud-kasir-001',
      'email': 'kasir@umkm.id',
      'username': 'kasir',
      'password': '123456',
      'full_name': 'Siti Rahma (Kasir)',
      'role': 'kasir',
      'avatar_url':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      'phone_number': '+62 813-2233-4455',
      'store_name': 'CloudPOS • Cabang Utama UMKM',
      'store_address': 'Jl. Asia Afrika No. 88, Kota Bandung',
      'bio': 'Kasir Operasional Harian',
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  /// Mengambil daftar seluruh akun yang terdaftar
  Future<List<Map<String, dynamic>>> getRegisteredAccounts() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyAccounts);
    if (raw == null || raw.trim().isEmpty) {
      await prefs.setString(_keyAccounts, jsonEncode(_defaultAccounts));
      return List<Map<String, dynamic>>.from(_defaultAccounts);
    }
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return List<Map<String, dynamic>>.from(_defaultAccounts);
    }
  }

  /// Autentikasi Pengguna: Mencocokkan Email/Username DAN Password secara ketat
  Future<UserProfile> authenticateUser({
    required String emailOrUsername,
    required String password,
  }) async {
    final cleanInput = emailOrUsername.trim().toLowerCase();
    final cleanPass = password.trim();

    final accounts = await getRegisteredAccounts();

    // 1. Cari akun berdasarkan email ATAU username
    Map<String, dynamic>? matchedAccount;
    for (final acc in accounts) {
      final accEmail = (acc['email'] ?? '').toString().toLowerCase();
      final accUser = (acc['username'] ?? '').toString().toLowerCase();

      if (accEmail == cleanInput || accUser == cleanInput) {
        matchedAccount = acc;
        break;
      }
      // Jika input tanpa domain misal "andriyan", cocokkan dengan "andriyan@..."
      if (accEmail.startsWith('$cleanInput@') || accEmail.split('@').first == cleanInput) {
        matchedAccount = acc;
        break;
      }
    }

    if (matchedAccount == null) {
      throw Exception(
        'Akun "$emailOrUsername" tidak ditemukan. Pastikan email/ID benar atau klik Sign Up untuk mendaftar.',
      );
    }

    // 2. Verifikasi Password secara ketat
    final storedPass = (matchedAccount['password'] ?? '').toString();
    if (storedPass != cleanPass) {
      throw Exception(
        'Password yang Anda masukkan salah. Silakan periksa kembali!',
      );
    }

    final profile = UserProfile.fromMap(matchedAccount);
    await saveActiveSession(profile);
    return profile;
  }

  /// Registrasi Akun Baru (Sign Up) dan simpan permanen ke database
  Future<UserProfile> registerUser({
    required String fullName,
    required String email,
    required String password,
    String role = 'admin',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = fullName.trim();
    final cleanPass = password.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw Exception('Format email tidak valid.');
    }
    if (cleanPass.length < 6) {
      throw Exception('Password minimal 6 karakter.');
    }

    final accounts = await getRegisteredAccounts();
    final alreadyExists = accounts.any(
      (a) => (a['email'] ?? '').toString().toLowerCase() == cleanEmail,
    );

    if (alreadyExists) {
      throw Exception('Email "$email" sudah terdaftar. Silakan gunakan Log In.');
    }

    final newAccount = {
      'id': 'cloud-user-${DateTime.now().millisecondsSinceEpoch}',
      'email': cleanEmail,
      'username': cleanEmail.split('@').first,
      'password': cleanPass,
      'full_name': cleanName.isNotEmpty ? cleanName : 'Pemilik Toko UMKM',
      'role': role,
      'avatar_url':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      'phone_number': '+62 812-3456-7890',
      'store_name': 'CloudPOS • Toko UMKM',
      'store_address': 'Indonesia',
      'bio': 'Pengelola Toko CloudPOS',
      'created_at': DateTime.now().toIso8601String(),
    };

    accounts.add(newAccount);
    final prefs = await _getPrefs();
    await prefs.setString(_keyAccounts, jsonEncode(accounts));

    final profile = UserProfile.fromMap(newAccount);
    await saveActiveSession(profile);
    return profile;
  }

  /// Update Profil Pengguna Tersimpan
  Future<UserProfile> updateStoredProfile(UserProfile updated) async {
    final accounts = await getRegisteredAccounts();
    final idx = accounts.indexWhere(
      (a) => (a['id'] ?? '').toString() == updated.id ||
          (a['email'] ?? '').toString().toLowerCase() == updated.email.toLowerCase(),
    );

    final map = updated.toMap();
    if (idx != -1) {
      // Pertahankan password
      map['password'] = accounts[idx]['password'] ?? '123456';
      map['username'] = accounts[idx]['username'] ?? updated.email.split('@').first;
      accounts[idx] = map;
    } else {
      map['password'] = '123456';
      accounts.add(map);
    }

    final prefs = await _getPrefs();
    await prefs.setString(_keyAccounts, jsonEncode(accounts));
    await saveActiveSession(updated);
    return updated;
  }

  /// Sesi Aktif (Auto-Login saat buka aplikasi di HP/Browser)
  Future<void> saveActiveSession(UserProfile user) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyActiveSession, jsonEncode(user.toMap()));
  }

  Future<UserProfile?> getActiveSession() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyActiveSession);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearActiveSession() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyActiveSession);
  }

  // ===========================================================================
  // 2. MANAJEMEN PRODUK PERMANEN (TAMBAH, EDIT, HAPUS PERSISTEN)
  // ===========================================================================

  /// Mengambil daftar produk dari database permanen.
  /// Jika belum ada, otomatis inisialisasi dengan 60 produk katalog lengkap.
  Future<List<ProductModel>> getProducts() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyProducts);

    if (raw == null || raw.trim().isEmpty) {
      final initialList = ProductService.demoProductsRef;
      await saveAllProducts(initialList);
      return List<ProductModel>.from(initialList);
    }

    try {
      final decoded = jsonDecode(raw) as List;
      final list = decoded
          .map((item) => ProductModel.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
      if (list.isEmpty) {
        final initialList = ProductService.demoProductsRef;
        await saveAllProducts(initialList);
        return List<ProductModel>.from(initialList);
      }
      return list;
    } catch (_) {
      return List<ProductModel>.from(ProductService.demoProductsRef);
    }
  }

  Future<void> saveAllProducts(List<ProductModel> products) async {
    final prefs = await _getPrefs();
    final maps = products.map((p) => p.toFullMap()).toList();
    await prefs.setString(_keyProducts, jsonEncode(maps));
  }

  /// Tambah Produk Baru dan simpan permanen
  Future<ProductModel> addProduct(ProductModel product) async {
    final products = await getProducts();

    final duplicateSku = products.any(
      (p) => p.sku.trim().toLowerCase() == product.sku.trim().toLowerCase(),
    );
    if (duplicateSku) {
      throw Exception('SKU "${product.sku}" sudah digunakan oleh produk lain.');
    }

    final created = product.copyWith(
      id: product.id.isNotEmpty
          ? product.id
          : 'prod-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    products.insert(0, created);
    await saveAllProducts(products);
    return created;
  }

  /// Update Produk dan simpan permanen
  Future<ProductModel> updateProduct(ProductModel product) async {
    final products = await getProducts();
    final idx = products.indexWhere((p) => p.id == product.id);

    if (idx == -1) {
      throw Exception('Produk tidak ditemukan di database.');
    }

    final duplicateSku = products.any(
      (p) => p.id != product.id &&
          p.sku.trim().toLowerCase() == product.sku.trim().toLowerCase(),
    );
    if (duplicateSku) {
      throw Exception('SKU "${product.sku}" sudah digunakan oleh produk lain.');
    }

    final updated = product.copyWith(updatedAt: DateTime.now());
    products[idx] = updated;
    await saveAllProducts(products);
    return updated;
  }

  /// Hapus Produk dan simpan permanen (Benar-benar terhapus!)
  Future<void> deleteProduct(String id) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == id);
    await saveAllProducts(products);
  }

  /// Pengurangan stok otomatis saat transaksi POS berhasil
  Future<void> decreaseProductStock(String productId, int quantity) async {
    final products = await getProducts();
    final idx = products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final current = products[idx];
      final newStock = (current.stock - quantity).clamp(0, 999999);
      products[idx] = current.copyWith(stock: newStock, updatedAt: DateTime.now());
      await saveAllProducts(products);
    }
  }

  // ===========================================================================
  // 3. MANAJEMEN KATEGORI PERMANEN
  // ===========================================================================

  static final List<CategoryModel> _defaultCategories = [
    CategoryModel(id: 'cat-1', name: 'Minuman', createdAt: DateTime.now()),
    CategoryModel(id: 'cat-2', name: 'Makanan', createdAt: DateTime.now()),
    CategoryModel(id: 'cat-3', name: 'Roti', createdAt: DateTime.now()),
    CategoryModel(id: 'cat-4', name: 'Cemilan', createdAt: DateTime.now()),
    CategoryModel(id: 'cat-5', name: 'Sembako', createdAt: DateTime.now()),
    CategoryModel(id: 'cat-6', name: 'Kebutuhan', createdAt: DateTime.now()),
  ];

  Future<List<CategoryModel>> getCategories() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyCategories);
    if (raw == null || raw.trim().isEmpty) {
      await saveAllCategories(_defaultCategories);
      return List<CategoryModel>.from(_defaultCategories);
    }
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((item) => CategoryModel.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return List<CategoryModel>.from(_defaultCategories);
    }
  }

  Future<void> saveAllCategories(List<CategoryModel> categories) async {
    final prefs = await _getPrefs();
    final maps = categories.map((c) => c.toMap()).toList();
    await prefs.setString(_keyCategories, jsonEncode(maps));
  }

  Future<CategoryModel> addCategory(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw Exception('Nama kategori tidak boleh kosong.');

    final categories = await getCategories();
    final exists = categories.any(
      (c) => c.name.trim().toLowerCase() == clean.toLowerCase(),
    );
    if (exists) throw Exception('Kategori "$clean" sudah ada.');

    final created = CategoryModel(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: clean,
      createdAt: DateTime.now(),
    );
    categories.add(created);
    await saveAllCategories(categories);
    return created;
  }

  Future<void> deleteCategory(String id) async {
    final categories = await getCategories();
    final products = await getProducts();

    final hasProducts = products.any((p) => p.categoryId == id);
    if (hasProducts) {
      throw Exception(
        'Kategori tidak dapat dihapus karena masih memiliki produk aktif.',
      );
    }

    categories.removeWhere((c) => c.id == id);
    await saveAllCategories(categories);
  }

  // ===========================================================================
  // 4. MANAJEMEN TRANSAKSI & RIWAYAT PENJUALAN PERMANEN
  // ===========================================================================

  Future<List<TransactionModel>> getTransactions() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyTransactions);
    if (raw == null || raw.trim().isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((item) => TransactionModel.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<TransactionModel> addTransaction(TransactionModel tx) async {
    final transactions = await getTransactions();
    transactions.insert(0, tx);

    // Otomatis kurangi stok setiap produk yang dibeli
    for (final detail in tx.details) {
      if (detail.productId.isNotEmpty) {
        await decreaseProductStock(detail.productId, detail.quantity);
      }
    }

    final prefs = await _getPrefs();
    final maps = transactions.map((t) => t.toMap()).toList();
    await prefs.setString(_keyTransactions, jsonEncode(maps));
    return tx;
  }

  // ===========================================================================
  // 5. PENYIMPANAN KONEKSI SUPABASE DARI UI APLIKASI
  // ===========================================================================

  Future<void> saveCustomSupabaseCredentials({
    required String url,
    required String anonKey,
  }) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyCustomSupabaseUrl, url.trim());
    await prefs.setString(_keyCustomSupabaseKey, anonKey.trim());
  }

  Future<Map<String, String>> getCustomSupabaseCredentials() async {
    final prefs = await _getPrefs();
    return {
      'url': prefs.getString(_keyCustomSupabaseUrl) ?? '',
      'key': prefs.getString(_keyCustomSupabaseKey) ?? '',
    };
  }

  Future<void> clearCustomSupabaseCredentials() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyCustomSupabaseUrl);
    await prefs.remove(_keyCustomSupabaseKey);
  }
}

