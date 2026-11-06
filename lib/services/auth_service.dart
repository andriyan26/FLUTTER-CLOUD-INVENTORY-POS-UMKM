import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/user_profile.dart';
import 'local_db_service.dart';

class AuthService {
  final LocalDbService _localDb = LocalDbService();

  bool get isDemoMode => !SupabaseConfig.isConfigured;

  /// Cek session aktif (Supabase Auth atau Local Session yang tersimpan di HP/Browser)
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

    return await _localDb.getActiveSession();
  }

  /// Login dengan Email/Username & Password yang diketik pengguna sendiri
  /// Validasi KETAT: Jika email tidak ditemukan atau password salah, DITOLAK!
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
        throw Exception('Gagal masuk. Periksa kembali email dan password Anda.');
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

    // Database Lokal Terverifikasi: Mencocokkan akun & password yang tersimpan
    await Future.delayed(const Duration(milliseconds: 320));
    return await _localDb.authenticateUser(
      emailOrUsername: input,
      password: password,
    );
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

    await _localDb.updateStoredProfile(updated);
    return updated;
  }

  /// Registrasi akun baru (Tersimpan permanen di database)
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
        throw Exception('Pendaftaran akun gagal. Silakan coba kembali.');
      }

      return UserProfile(
        id: user.id,
        email: email.trim(),
        fullName: fullName.trim(),
        role: role,
        avatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
        createdAt: DateTime.now(),
      );
    }

    // Simpan akun baru secara permanen di Database Lokal
    await Future.delayed(const Duration(milliseconds: 320));
    return await _localDb.registerUser(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }

  /// Sign Out / Logout
  Future<void> signOut() async {
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
    await _localDb.clearActiveSession();
  }
}
