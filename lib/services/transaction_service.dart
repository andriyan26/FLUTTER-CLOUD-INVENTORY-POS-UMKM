import '../core/config/supabase_config.dart';
import '../models/cart_item_model.dart';
import '../models/transaction_model.dart';
import 'product_service.dart';

class TransactionService {
  static final List<TransactionModel> _demoTransactions = [
    TransactionModel(
      id: 'tx-1001',
      transactionCode: 'INV-20261106-001',
      customerName: 'Budi Santoso',
      subtotal: 51000,
      total: 51000,
      paymentMethod: 'QRIS',
      amountPaid: 51000,
      changeAmount: 0,
      userId: 'demo-admin-001',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      details: const [
        TransactionDetailModel(
          id: 'txd-1',
          transactionId: 'tx-1001',
          productId: 'prod-1',
          productName: 'Kopi Susu',
          price: 18000,
          quantity: 2,
          subtotal: 36000,
        ),
        TransactionDetailModel(
          id: 'txd-2',
          transactionId: 'tx-1001',
          productId: 'prod-2',
          productName: 'Keripik Pisang',
          price: 15000,
          quantity: 1,
          subtotal: 15000,
        ),
      ],
    ),
    TransactionModel(
      id: 'tx-1002',
      transactionCode: 'INV-20261106-002',
      customerName: 'Pelanggan Umum',
      subtotal: 34000,
      total: 34000,
      paymentMethod: 'Cash',
      amountPaid: 50000,
      changeAmount: 16000,
      userId: 'demo-admin-001',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      details: const [
        TransactionDetailModel(
          id: 'txd-3',
          transactionId: 'tx-1002',
          productId: 'prod-3',
          productName: 'Roti Cokelat',
          price: 12000,
          quantity: 2,
          subtotal: 24000,
        ),
        TransactionDetailModel(
          id: 'txd-4',
          transactionId: 'tx-1002',
          productId: 'prod-6',
          productName: 'Makaroni Pedas',
          price: 10000,
          quantity: 1,
          subtotal: 10000,
        ),
      ],
    ),
    TransactionModel(
      id: 'tx-1003',
      transactionCode: 'INV-20261105-088',
      customerName: 'Warung Bu Dewi',
      subtotal: 89500,
      total: 89500,
      paymentMethod: 'Transfer',
      amountPaid: 89500,
      changeAmount: 0,
      userId: 'demo-admin-001',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      details: const [
        TransactionDetailModel(
          id: 'txd-5',
          transactionId: 'tx-1003',
          productId: 'prod-9',
          productName: 'Beras',
          price: 72000,
          quantity: 1,
          subtotal: 72000,
        ),
        TransactionDetailModel(
          id: 'txd-6',
          transactionId: 'tx-1003',
          productId: 'prod-10',
          productName: 'Gula Pasir',
          price: 17500,
          quantity: 1,
          subtotal: 17500,
        ),
      ],
    ),
  ];

  Future<List<TransactionModel>> fetchTransactions() async {
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final response = await client
          .from('transactions')
          .select('*, transaction_details(*)')
          .order('created_at', ascending: false);
      return (response as List)
          .map((item) => TransactionModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return List<TransactionModel>.from(_demoTransactions);
  }

  /// Proses Checkout dengan Atomic Stock Validation & Pengurangan Stok
  Future<TransactionModel> processCheckout({
    required String customerName,
    required String paymentMethod,
    required int amountPaid,
    required List<CartItemModel> items,
    required String userId,
  }) async {
    if (items.isEmpty) {
      throw Exception('Keranjang masih kosong.');
    }

    final now = DateTime.now();
    final datePart =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomSuffix =
        (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    final txCode = 'INV-$datePart-$randomSuffix';

    final subtotal = items.fold<int>(0, (sum, item) => sum + item.subtotal);
    final total = subtotal;

    if (amountPaid < total) {
      throw Exception('Nominal pembayaran kurang dari total tagihan.');
    }

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      final payloadItems = items
          .map((e) => {
                'product_id': e.product.id,
                'quantity': e.quantity,
              })
          .toList();

      await client.rpc('process_pos_checkout', params: {
        'p_transaction_code': txCode,
        'p_customer_name': customerName.trim().isEmpty
            ? 'Pelanggan Umum'
            : customerName.trim(),
        'p_payment_method': paymentMethod,
        'p_amount_paid': amountPaid,
        'p_items': payloadItems,
      });

      final fetched = await client
          .from('transactions')
          .select('*, transaction_details(*)')
          .eq('transaction_code', txCode)
          .single();

      return TransactionModel.fromMap(fetched);
    }

    // Validasi & Atomic Update untuk Mode Demo
    final demoProducts = ProductService.demoProductsRef;
    for (final cartItem in items) {
      final idx = demoProducts.indexWhere((p) => p.id == cartItem.product.id);
      if (idx == -1) {
        throw Exception('Produk "${cartItem.product.name}" tidak ditemukan.');
      }
      if (demoProducts[idx].stock < cartItem.quantity) {
        throw Exception(
          'Stok "${demoProducts[idx].name}" tidak mencukupi (Tersisa: ${demoProducts[idx].stock}).',
        );
      }
    }

    final txId = 'tx-${now.millisecondsSinceEpoch}';
    final List<TransactionDetailModel> details = [];

    for (final cartItem in items) {
      final idx = demoProducts.indexWhere((p) => p.id == cartItem.product.id);
      final currentProd = demoProducts[idx];
      demoProducts[idx] = currentProd.copyWith(
        stock: currentProd.stock - cartItem.quantity,
        updatedAt: DateTime.now(),
      );

      details.add(
        TransactionDetailModel(
          id: 'txd-${now.microsecondsSinceEpoch}-${details.length}',
          transactionId: txId,
          productId: currentProd.id,
          productName:
              cartItem.selectedVariant == 'Reguler' || cartItem.selectedVariant.isEmpty
                  ? currentProd.name
                  : '${currentProd.name} (${cartItem.selectedVariant})',
          price: cartItem.unitPrice,
          quantity: cartItem.quantity,
          subtotal: cartItem.subtotal,
        ),
      );
    }

    final createdTx = TransactionModel(
      id: txId,
      transactionCode: txCode,
      customerName:
          customerName.trim().isEmpty ? 'Pelanggan Umum' : customerName.trim(),
      subtotal: subtotal,
      total: total,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      changeAmount: amountPaid - total,
      userId: userId,
      createdAt: now,
      details: details,
    );

    _demoTransactions.insert(0, createdTx);
    return createdTx;
  }
}

