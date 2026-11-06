import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_inventory_pos_umkm/main.dart';
import 'package:cloud_inventory_pos_umkm/core/utils/currency_formatter.dart';
import 'package:cloud_inventory_pos_umkm/core/utils/validators.dart';
import 'package:cloud_inventory_pos_umkm/models/product_model.dart';
import 'package:cloud_inventory_pos_umkm/providers/cart_provider.dart';

void main() {
  group('Cloud Inventory POS UMKM — Unit & Widget Tests', () {
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

    test('CartProvider mencegah pembelian melebihi stok', () {
      final cart = CartProvider();
      final product = ProductModel(
        id: 'test-1',
        sku: 'UMKM-001',
        name: 'Kopi Susu',
        categoryId: 'cat-1',
        price: 18000,
        stock: 2,
        description: 'Kopi susu',
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

    testWidgets('Aplikasi merender SplashScreen dengan brand CloudPOS.',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CloudInventoryPosApp());
      expect(find.textContaining('Smart inventory'), findsOneWidget);
      // Selesaikan timer splash screen agar tidak menyisakan pending timer
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });
}

