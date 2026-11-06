import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // Maksimal 5 MB
  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
  ];

  /// Upload gambar produk ke Supabase Storage atau konversi langsung ke Data URI di Mode Demo
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    return _uploadOrEncode(
      bytes: bytes,
      fileName: fileName,
      folder: 'products',
    );
  }

  /// Upload foto profil / avatar pengguna
  Future<String> uploadAvatarImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    return _uploadOrEncode(
      bytes: bytes,
      fileName: fileName,
      folder: 'avatars',
    );
  }

  Future<String> _uploadOrEncode({
    required Uint8List bytes,
    required String fileName,
    required String folder,
  }) async {
    if (bytes.lengthInBytes > maxFileSizeBytes) {
      throw Exception('Ukuran gambar melebihi batas maksimal 5 MB.');
    }

    final rawExt = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';
    final ext = allowedExtensions.contains(rawExt) ? rawExt : 'jpg';
    final mimeType = 'image/${ext == 'jpg' ? 'jpeg' : ext}';

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      try {
        final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
        final path =
            '$folder/${DateTime.now().millisecondsSinceEpoch}_$safeName';
        await client.storage
            .from(AppConstants.productImagesBucket)
            .uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(
                contentType: mimeType,
                upsert: true,
              ),
            );
        return client.storage
            .from(AppConstants.productImagesBucket)
            .getPublicUrl(path);
      } catch (_) {
        // Fallback ke Data URI agar gambar yang dipilih pengguna tetap tampil 100%
      }
    }

    await Future.delayed(const Duration(milliseconds: 220));
    final b64 = base64Encode(bytes);
    return 'data:$mimeType;base64,$b64';
  }
}
