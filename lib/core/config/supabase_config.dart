import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/local_db_service.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String envSupabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String envSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool _isInitialized = false;
  static String _activeUrl = envSupabaseUrl;
  static String _activeAnonKey = envSupabaseAnonKey;

  /// Menentukan apakah Supabase sudah dikonfigurasi dengan URL & Anon Key valid.
  static bool get isConfigured =>
      _isInitialized &&
      _activeUrl.isNotEmpty &&
      _activeAnonKey.isNotEmpty &&
      _activeUrl.startsWith('https://');

  static String get activeUrl => _activeUrl;

  static SupabaseClient? get clientOrNull {
    if (!isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static Future<void> initialize({
    String? customUrl,
    String? customAnonKey,
  }) async {
    String url = (customUrl ?? envSupabaseUrl).trim();
    String key = (customAnonKey ?? envSupabaseAnonKey).trim();

    // Jika environment kosong, cek apakah pengguna pernah menyimpan koneksi di aplikasi
    if (url.isEmpty || key.isEmpty) {
      try {
        final saved = await LocalDbService().getCustomSupabaseCredentials();
        if (saved['url']?.isNotEmpty == true && saved['key']?.isNotEmpty == true) {
          url = saved['url']!.trim();
          key = saved['key']!.trim();
        }
      } catch (_) {}
    }

    if (url.isEmpty || key.isEmpty || !url.startsWith('https://')) {
      _isInitialized = false;
      return;
    }

    try {
      if (!_isInitialized) {
        await Supabase.initialize(
          url: url,
          anonKey: key,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
        );
        _activeUrl = url;
        _activeAnonKey = key;
        _isInitialized = true;
      }
    } catch (_) {
      _isInitialized = false;
    }
  }

  /// Hubungkan ke Supabase secara langsung dari UI Pengaturan
  static Future<bool> connectCustom({
    required String url,
    required String anonKey,
  }) async {
    final cleanUrl = url.trim();
    final cleanKey = anonKey.trim();

    if (!cleanUrl.startsWith('https://') || cleanKey.length < 20) {
      throw Exception('Format URL Supabase (https://...) atau Anon Key tidak valid.');
    }

    try {
      await Supabase.initialize(
        url: cleanUrl,
        anonKey: cleanKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _activeUrl = cleanUrl;
      _activeAnonKey = cleanKey;
      _isInitialized = true;

      await LocalDbService().saveCustomSupabaseCredentials(
        url: cleanUrl,
        anonKey: cleanKey,
      );
      return true;
    } catch (e) {
      _isInitialized = false;
      throw Exception('Gagal menghubungkan ke Supabase: ${e.toString()}');
    }
  }

  /// Putuskan koneksi Supabase dan kembali ke Database Lokal
  static Future<void> disconnectCustom() async {
    await LocalDbService().clearCustomSupabaseCredentials();
    _activeUrl = envSupabaseUrl;
    _activeAnonKey = envSupabaseAnonKey;
    _isInitialized = false;
  }
}

