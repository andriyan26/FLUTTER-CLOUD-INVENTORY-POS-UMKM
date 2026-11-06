import '../models/product_model.dart';
import '../models/transaction_model.dart';

class TopProductStat {
  final String productName;
  final int totalQuantitySold;
  final int totalRevenue;

  const TopProductStat({
    required this.productName,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });
}

class ReportService {
  /// Menghitung ringkasan penjualan berdasarkan filter periode ('Harian', 'Mingguan', 'Bulanan', 'Semua')
  Map<String, dynamic> buildReportSummary({
    required List<TransactionModel> transactions,
    required List<ProductModel> products,
    required String period,
  }) {
    final now = DateTime.now();
    final filtered = transactions.where((tx) {
      final diff = now.difference(tx.createdAt);
      if (period == 'Harian') {
        return tx.createdAt.year == now.year &&
            tx.createdAt.month == now.month &&
            tx.createdAt.day == now.day;
      } else if (period == 'Mingguan') {
        return diff.inDays <= 7;
      } else if (period == 'Bulanan') {
        return tx.createdAt.year == now.year && tx.createdAt.month == now.month;
      }
      return true;
    }).toList();

    final int totalRevenue =
        filtered.fold<int>(0, (sum, tx) => sum + tx.total);
    final int totalTxCount = filtered.length;

    final Map<String, TopProductStat> productAgg = {};
    for (final tx in filtered) {
      for (final d in tx.details) {
        final existing = productAgg[d.productName];
        if (existing == null) {
          productAgg[d.productName] = TopProductStat(
            productName: d.productName,
            totalQuantitySold: d.quantity,
            totalRevenue: d.subtotal,
          );
        } else {
          productAgg[d.productName] = TopProductStat(
            productName: d.productName,
            totalQuantitySold: existing.totalQuantitySold + d.quantity,
            totalRevenue: existing.totalRevenue + d.subtotal,
          );
        }
      }
    }

    final topProducts = productAgg.values.toList()
      ..sort((a, b) => b.totalQuantitySold.compareTo(a.totalQuantitySold));

    final lowStockProducts = products.where((p) => p.stock <= 10).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));

    return {
      'filteredTransactions': filtered,
      'totalRevenue': totalRevenue,
      'totalTransactions': totalTxCount,
      'topProducts': topProducts,
      'lowStockProducts': lowStockProducts,
    };
  }

  /// Menghasilkan string CSV untuk fitur Export Laporan
  String generateCsv(List<TransactionModel> transactions) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Nomor Transaksi,Tanggal,Pelanggan,Metode Pembayaran,Subtotal (Rp),Total (Rp),Dibayar (Rp),Kembalian (Rp)',
    );
    for (final tx in transactions) {
      final safeCustomer = tx.customerName.replaceAll(',', ' ');
      buffer.writeln(
        '${tx.transactionCode},${tx.createdAt.toIso8601String()},$safeCustomer,${tx.paymentMethod},${tx.subtotal},${tx.total},${tx.amountPaid},${tx.changeAmount}',
      );
    }
    return buffer.toString();
  }
}

