import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/user_profile.dart';

class AuthService {
  UserProfile? _demoSessionUser;

  bool get isDemoMode => !SupabaseConfig.isConfigured;

  /// Cek session aktif (Supabase Auth atau Demo Session yang tersimpan)
  Future<UserProfile?> getCurrentUser() async {
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final session = client.auth.currentSession;
      final user = client.auth.currentUser;
      if (session == null || user == null) return null;

      try {
        final data = await client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          return UserProfile.fromMap(data, email: user.email ?? '');
        }
      } catch (_) {}

      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name']?.toString() ?? 'Admin UMKM',
        role: user.userMetadata?['role']?.toString() ?? 'admin',
        createdAt: DateTime.now(),
      );
    }

    return _demoSessionUser;
  }

  /// Login dengan Email & Password (Supabase Auth atau Demo Mode Terpisah)
  Future<UserProfile> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    final input = emailOrUsername.trim();
    if (input.isEmpty || password.length < 6) {
      throw Exception('Email/username dan password (min. 6 karakter) wajib valid.');
    }

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final email = input.contains('@') ? input : '$input@umkm.id';
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception('Gagal masuk. Periksa kembali kredensial Anda.');
      }

      final profileData = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileData != null) {
        return UserProfile.fromMap(profileData, email: user.email ?? email);
      }

      return UserProfile(
        id: user.id,
        email: user.email ?? email,
        fullName: user.userMetadata?['full_name']?.toString() ?? 'User UMKM',
        role: user.userMetadata?['role']?.toString() ?? 'admin',
        createdAt: DateTime.now(),
      );
    }

    // Demo Mode Terpisah (ketika SUPABASE_URL belum dikonfigurasi)
    await Future.delayed(const Duration(milliseconds: 450));
    final lower = input.toLowerCase();

    if (password != '123456' && password != 'admin123' && password != 'kasir123') {
      throw Exception(
        'Password salah. Untuk mode demo gunakan: 123456 (atau admin123 / kasir123).',
      );
    }

    final isKasir = lower.contains('kasir');
    _demoSessionUser = UserProfile(
      id: isKasir ? 'demo-kasir-002' : 'demo-admin-001',
      email: lower.contains('@') ? lower : '$lower@umkm.id',
      fullName: isKasir ? 'Siti Rahma (Kasir)' : 'Andriyan (Admin UMKM)',
      role: isKasir ? 'kasir' : 'admin',
      createdAt: DateTime.now(),
    );
    return _demoSessionUser!;
  }

  /// Registrasi akun baru
  Future<UserProfile> signUp({
    required String fullName,
    required String email,
    required String password,
    String role = 'admin',
  }) async {
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          'role': role,
        },
      );
      final user = response.user;
      if (user == null) {
        throw Exception('Registrasi gagal. Coba gunakan email lain.');
      }
      return UserProfile(
        id: user.id,
        email: email.trim(),
        fullName: fullName.trim(),
        role: role,
        createdAt: DateTime.now(),
      );
    }

    await Future.delayed(const Duration(milliseconds: 400));
    _demoSessionUser = UserProfile(
      id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      fullName: fullName.trim(),
      role: role,
      createdAt: DateTime.now(),
    );
    return _demoSessionUser!;
  }

  /// Logout & hapus session
  Future<void> signOut() async {
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      await client.auth.signOut();
    }
    _demoSessionUser = null;
  }
}

