import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/user_profile.dart';

class AuthService {
  UserProfile? _demoSessionUser;

  bool get isDemoMode => !SupabaseConfig.isConfigured;

  /// Cek session aktif (Supabase Auth atau Cloud Session yang tersimpan)
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
        fullName: user.userMetadata?['full_name']?.toString() ?? 'Andriyan',
        role: user.userMetadata?['role']?.toString() ?? 'admin',
        avatarUrl: user.userMetadata?['avatar_url']?.toString() ?? '',
        phoneNumber: user.userMetadata?['phone_number']?.toString() ??
            '+62 812-8899-2026',
        storeName: user.userMetadata?['store_name']?.toString() ??
            'CloudPOS • Cabang Utama',
        storeAddress: user.userMetadata?['store_address']?.toString() ??
            'Jl. Asia Afrika No. 88, Bandung',
        bio: user.userMetadata?['bio']?.toString() ??
            'Founder & Head of Operations UMKM CloudPOS',
        createdAt: DateTime.now(),
      );
    }

    return _demoSessionUser;
  }

  /// Login dengan Email/Username & Password yang diketik pengguna sendiri
  Future<UserProfile> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    final input = emailOrUsername.trim();
    if (input.isEmpty || password.length < 6) {
      throw Exception(
        'Email/ID dan password (minimal 6 karakter) wajib diisi dengan benar.',
      );
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
        fullName: user.userMetadata?['full_name']?.toString() ?? 'Andriyan',
        role: user.userMetadata?['role']?.toString() ?? 'admin',
        avatarUrl: user.userMetadata?['avatar_url']?.toString() ?? '',
        createdAt: DateTime.now(),
      );
    }

    // Cloud Session (ketika SUPABASE_URL belum dikonfigurasi)
    await Future.delayed(const Duration(milliseconds: 380));
    final lower = input.toLowerCase();

    // Jika sebelumnya sudah edit profil di sesi ini, pertahankan perubahannya
    if (_demoSessionUser != null &&
        _demoSessionUser!.email.toLowerCase() ==
            (lower.contains('@') ? lower : '$lower@umkm.id')) {
      return _demoSessionUser!;
    }

    final isKasir = lower.contains('kasir');
    final normalizedEmail = lower.contains('@') ? lower : '$lower@umkm.id';

    String resolvedName = 'Andriyan (Admin UMKM)';
    if (isKasir) {
      resolvedName = 'Siti Rahma (Kasir)';
    } else if (!lower.contains('dailyflutterui') &&
        !lower.contains('andriyan') &&
        !lower.contains('admin')) {
      final rawPrefix = input.split('@').first.replaceAll('.', ' ').trim();
      if (rawPrefix.isNotEmpty) {
        resolvedName =
            '${rawPrefix[0].toUpperCase()}${rawPrefix.substring(1)} (Admin UMKM)';
      }
    }

    _demoSessionUser = UserProfile(
      id: isKasir ? 'cloud-kasir-002' : 'cloud-admin-001',
      email: normalizedEmail,
      fullName: resolvedName,
      role: isKasir ? 'kasir' : 'admin',
      avatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      phoneNumber: '+62 812-8899-2026',
      storeName: 'CloudPOS • Cabang Utama UMKM',
      storeAddress: 'Jl. Asia Afrika No. 88, Kota Bandung',
      bio: 'Founder & Senior Store Manager CloudPOS UMKM',
      createdAt: DateTime.now(),
    );
    return _demoSessionUser!;
  }

  /// Update Profil Pengguna (Nama, Foto Avatar, Toko, Role, Nomor HP, Alamat)
  Future<UserProfile> updateProfile(UserProfile updated) async {
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      try {
        await client.from('profiles').upsert({
          'id': updated.id,
          'full_name': updated.fullName,
          'role': updated.role,
        });
        await client.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': updated.fullName,
              'role': updated.role,
              'avatar_url': updated.avatarUrl,
              'phone_number': updated.phoneNumber,
              'store_name': updated.storeName,
              'store_address': updated.storeAddress,
              'bio': updated.bio,
            },
          ),
        );
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 220));
    _demoSessionUser = updated;
    return updated;
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
      id: 'cloud-${DateTime.now().millisecondsSinceEpoch}',
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
