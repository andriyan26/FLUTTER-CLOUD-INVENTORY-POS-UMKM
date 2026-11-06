import 'package:supabase_flutter/supabase_flutter.dart';

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
    final url = (customUrl ?? envSupabaseUrl).trim();
    final key = (customAnonKey ?? envSupabaseAnonKey).trim();

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
}

