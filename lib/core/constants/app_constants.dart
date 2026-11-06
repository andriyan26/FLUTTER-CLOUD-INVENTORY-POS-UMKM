class AppConstants {
  AppConstants._();

  static const String appName = 'Cloud Inventory POS';
  static const String appBrandShort = 'CloudPOS.';
  static const String appTagline = 'Kelola Stok & Kasir UMKM Lebih Cepat';

  // Dimensi wajib sesuai instruksi: iPhone 13 (390 x 844 logical pixels)
  static const double iphone13Width = 390.0;
  static const double iphone13Height = 844.0;

  // Batas stok menipis
  static const int lowStockThreshold = 10;

  // Metode pembayaran resmi
  static const List<String> paymentMethods = ['Cash', 'Transfer', 'QRIS'];

  // Storage Bucket Supabase
  static const String productImagesBucket = 'product-images';
}
