class Validators {
  Validators._();

  /// Validasi email atau username sesuai Video 1 ("That email doesn't look right")
  static String? validateEmailOrUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email atau username wajib diisi';
    }
    final trimmed = value.trim();
    if (trimmed.contains('@')) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(trimmed)) {
        return "That email doesn't look right";
      }
    } else if (trimmed.length < 3) {
      return "That email doesn't look right";
    }
    return null;
  }

  /// Validasi password minimal 6 karakter sesuai Video 1 ("Use at least 6 characters")
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Use at least 6 characters';
    }
    if (value.length < 6) {
      return 'Use at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? validateNonNegativeInt(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9-]'), '');
    final parsed = int.tryParse(clean);
    if (parsed == null) {
      return '$fieldName harus berupa angka bulat';
    }
    if (parsed < 0) {
      return '$fieldName tidak boleh negatif';
    }
    return null;
  }

  static String? validateImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (!trimmed.startsWith('http://') &&
        !trimmed.startsWith('https://') &&
        !trimmed.startsWith('data:image/')) {
      return 'URL gambar harus diawali https://';
    }
    return null;
  }
}

