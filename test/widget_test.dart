import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_inventory_pos_umkm/core/utils/currency_formatter.dart';
import 'package:cloud_inventory_pos_umkm/core/utils/validators.dart';
import 'package:cloud_inventory_pos_umkm/core/widgets/custom_cached_image.dart';
import 'package:cloud_inventory_pos_umkm/models/product_model.dart';
import 'package:cloud_inventory_pos_umkm/models/user_profile.dart';
import 'package:cloud_inventory_pos_umkm/providers/cart_provider.dart';
import 'package:cloud_inventory_pos_umkm/providers/product_provider.dart';
import 'package:cloud_inventory_pos_umkm/services/report_service.dart';
import 'package:cloud_inventory_pos_umkm/services/transaction_service.dart';

void main() {
  group('Cloud Inventory POS UMKM — Quality Gate Tests', () {
    test('Validasi email dan password sesuai Konsep Video 1', () {
      expect(
        Validators.validateEmailOrUsername('dailyflutt@'),
        equals("That email doesn't look right"),
      );
      expect(
        Validators.validateEmailOrUsername('dailyflutterui@gmail.com'),
        isNull,
      );
      expect(
        Validators.validatePassword('123'),
        equals('Use at least 6 characters'),
      );
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('Format mata uang Rupiah akurat', () {
      final formatted = CurrencyFormatter.formatRupiah(18000);
      expect(formatted.contains('18.000'), isTrue);
    });

    test('CartProvider memvalidasi stok dan menghitung total dengan benar', () {
      final cart = CartProvider();
      final product = ProductModel(
        id: 'test-1',
        sku: 'UMKM-001',
        name: 'Kopi Susu',
        categoryId: 'cat-1',
        price: 18000,
        stock: 2,
        description: 'Kopi susu gula aren',
        images: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(cart.addToCart(product, quantity: 2), isNull);
      expect(cart.totalItemsCount, equals(2));
      expect(cart.total, equals(36000));

      // Penambahan melebihi stok harus ditolak
      final error = cart.addToCart(product, quantity: 1);
      expect(error, isNotNull);
      expect(cart.totalItemsCount, equals(2));
    });

    test('ProductProvider menampilkan barang baru secara otomatis di urutan #1', () async {
      final provider = ProductProvider();
      await provider.loadProducts();
      provider.setCategoryFilter('cat-99'); // Simulasi filter aktif sebelumnya

      final newProd = ProductModel(
        id: '',
        sku: 'UMKM-999',
        name: 'Es Matcha Spesial Baru',
        categoryId: 'cat-1',
        categoryName: 'Minuman & Kopi',
        price: 24000,
        stock: 30,
        description: 'Matcha Jepang asli',
        images: const [
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final ok = await provider.addProduct(newProd, isAdmin: true);
      expect(ok, isTrue);
      expect(provider.selectedCategoryId, equals('all'));
      expect(provider.filteredProducts.first.name, equals('Es Matcha Spesial Baru'));
    });

    test('ReportService mendeteksi produk stok menipis & membuat dokumen cetak', () async {
      final reportService = ReportService();
      final txService = TransactionService();
      final demoTx = await txService.fetchTransactions();

      final lowStockProd = ProductModel(
        id: 'p-low',
        sku: 'UMKM-006',
        name: 'Makaroni Pedas',
        categoryId: 'cat-2',
        price: 10000,
        stock: 5,
        description: 'Pedas',
        images: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final summaryHarian = reportService.buildReportSummary(
        transactions: demoTx,
        products: [lowStockProd],
        period: 'Harian',
      );
      final summaryBulanan = reportService.buildReportSummary(
        transactions: demoTx,
        products: [lowStockProd],
        period: 'Bulanan',
      );

      expect(
        (summaryBulanan['totalRevenue'] as int) >=
            (summaryHarian['totalRevenue'] as int),
        isTrue,
      );

      final html = reportService.generatePrintableReportHtml(
        period: 'Bulanan',
        paperFormat: 'A4',
        storeName: 'CloudPOS • Cabang Utama',
        storeAddress: 'Jl. Asia Afrika No. 88',
        storePhone: '+62 812-8899-2026',
        authorName: 'Andriyan',
        summary: summaryBulanan,
        includePaymentBreakdown: true,
        includeTopProducts: true,
        includeTransactions: true,
        includeLowStock: true,
        includeSignature: true,
      );
      expect(html.contains('LAPORAN PERIODE: BULANAN'), isTrue);
      expect(html.contains('VERIFIED'), isTrue);
    });

    test('UserProfile mendukung edit profil & decode upload foto Data URI', () {
      final profile = UserProfile(
        id: 'u-1',
        email: 'andriyan@umkm.id',
        fullName: 'Andriyan',
        role: 'admin',
        createdAt: DateTime.now(),
      );
      final updated = profile.copyWith(
        fullName: 'Andriyan Founder',
        storeName: 'CloudPOS Nusantara',
        avatarUrl:
            'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      );
      expect(updated.fullName, equals('Andriyan Founder'));
      expect(updated.storeName, equals('CloudPOS Nusantara'));
      final decoded = CustomProductImage.tryDecodeDataUri(updated.avatarUrl);
      expect(decoded, isNotNull);
      expect(decoded!.isNotEmpty, isTrue);
    });
  });
}
