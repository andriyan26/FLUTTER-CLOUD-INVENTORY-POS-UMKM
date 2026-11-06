import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  static const int maxFileSizeBytes = 3 * 1024 * 1024; // Maksimal 3 MB
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  /// Upload gambar ke Supabase Storage (dengan validasi format & ukuran)
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.lengthInBytes > maxFileSizeBytes) {
      throw Exception('Ukuran gambar melebihi batas maksimal 3 MB.');
    }

    final ext = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      throw Exception(
        'Format file .$ext tidak didukung. Gunakan JPG, PNG, atau WEBP.',
      );
    }

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final path =
          'products/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await client.storage.from(AppConstants.productImagesBucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}',
              upsert: true,
            ),
          );
      return client.storage
          .from(AppConstants.productImagesBucket)
          .getPublicUrl(path);
    }

    // Jika mode demo tanpa Supabase Storage aktif, kembalikan gambar kurasi berkualitas tinggi
    await Future.delayed(const Duration(milliseconds: 350));
    return 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=80';
  }
}

