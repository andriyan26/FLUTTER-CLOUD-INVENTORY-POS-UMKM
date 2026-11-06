import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_inventory_pos_umkm/core/utils/currency_formatter.dart';
import 'package:cloud_inventory_pos_umkm/core/utils/validators.dart';
import 'package:cloud_inventory_pos_umkm/models/product_model.dart';
import 'package:cloud_inventory_pos_umkm/providers/cart_provider.dart';
import 'package:cloud_inventory_pos_umkm/services/report_service.dart';

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

    test('ReportService mendeteksi produk stok menipis', () {
      final reportService = ReportService();
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
      final summary = reportService.buildReportSummary(
        transactions: const [],
        products: [lowStockProd],
        period: 'Semua',
      );
      final lowList = summary['lowStockProducts'] as List<ProductModel>;
      expect(lowList.length, equals(1));
      expect(lowList.first.sku, equals('UMKM-006'));
    });
  });
}
