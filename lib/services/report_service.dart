import '../core/utils/currency_formatter.dart';
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
        return diff.inDays <= 30;
      }
      return true;
    }).toList();

    final int totalRevenue =
        filtered.fold<int>(0, (sum, tx) => sum + tx.total);
    final int totalTxCount = filtered.length;
    final int averageOrderValue =
        totalTxCount > 0 ? (totalRevenue / totalTxCount).round() : 0;

    int totalItemsSold = 0;
    final Map<String, int> paymentTotals = {
      'QRIS': 0,
      'Cash': 0,
      'Transfer': 0,
    };
    final Map<String, int> paymentCounts = {
      'QRIS': 0,
      'Cash': 0,
      'Transfer': 0,
    };

    final Map<String, TopProductStat> productAgg = {};
    for (final tx in filtered) {
      final method = paymentTotals.containsKey(tx.paymentMethod)
          ? tx.paymentMethod
          : 'Cash';
      paymentTotals[method] = (paymentTotals[method] ?? 0) + tx.total;
      paymentCounts[method] = (paymentCounts[method] ?? 0) + 1;

      for (final d in tx.details) {
        totalItemsSold += d.quantity;
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
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final lowStockProducts = products.where((p) => p.stock <= 10).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));

    return {
      'filteredTransactions': filtered,
      'totalRevenue': totalRevenue,
      'totalTransactions': totalTxCount,
      'totalItemsSold': totalItemsSold,
      'averageOrderValue': averageOrderValue,
      'paymentTotals': paymentTotals,
      'paymentCounts': paymentCounts,
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

  /// Menghasilkan teks ringkasan WhatsApp siap kirim ke Owner / Grup UMKM
  String generateWhatsAppSummary({
    required String period,
    required String storeName,
    required String authorName,
    required Map<String, dynamic> summary,
  }) {
    final int totalRevenue = summary['totalRevenue'] as int;
    final int totalTx = summary['totalTransactions'] as int;
    final int totalItems = summary['totalItemsSold'] as int;
    final paymentTotals = summary['paymentTotals'] as Map<String, int>;
    final topProducts = summary['topProducts'] as List<TopProductStat>;

    final sb = StringBuffer();
    sb.writeln('*LAPORAN RESMI CLOUDPOS UMKM*');
    sb.writeln('Toko: *$storeName*');
    sb.writeln('Periode: *$period*');
    sb.writeln('Dicetak: ${CurrencyFormatter.formatDateTime(DateTime.now())}');
    sb.writeln('--------------------------------');
    sb.writeln(
      'Total Pendapatan: *${CurrencyFormatter.formatRupiah(totalRevenue)}*',
    );
    sb.writeln('Total Transaksi: *$totalTx Nota* ($totalItems Item Terjual)');
    sb.writeln('--------------------------------');
    sb.writeln('*Rincian Metode Pembayaran:*');
    sb.writeln(
      '• QRIS: ${CurrencyFormatter.formatRupiah(paymentTotals['QRIS'] ?? 0)}',
    );
    sb.writeln(
      '• Cash / Tunai: ${CurrencyFormatter.formatRupiah(paymentTotals['Cash'] ?? 0)}',
    );
    sb.writeln(
      '• Transfer: ${CurrencyFormatter.formatRupiah(paymentTotals['Transfer'] ?? 0)}',
    );
    if (topProducts.isNotEmpty) {
      sb.writeln('--------------------------------');
      sb.writeln('*Produk Terlaris:*');
      for (final p in topProducts.take(5)) {
        sb.writeln(
          '• ${p.productName} (${p.totalQuantitySold}x) = ${CurrencyFormatter.formatRupiah(p.totalRevenue)}',
        );
      }
    }
    sb.writeln('--------------------------------');
    sb.writeln('Penanggung Jawab: *$authorName*');
    return sb.toString();
  }

  /// Menghasilkan dokumen HTML Cetak (A4 Eksekutif / Thermal 80mm) untuk Printer / Save as PDF
  String generatePrintableReportHtml({
    required String period,
    required String paperFormat, // 'A4' atau 'Thermal80'
    required String storeName,
    required String storeAddress,
    required String storePhone,
    required String authorName,
    required Map<String, dynamic> summary,
    required bool includePaymentBreakdown,
    required bool includeTopProducts,
    required bool includeTransactions,
    required bool includeLowStock,
    required bool includeSignature,
  }) {
    final int totalRevenue = summary['totalRevenue'] as int;
    final int totalTx = summary['totalTransactions'] as int;
    final int totalItems = summary['totalItemsSold'] as int;
    final int avgOrder = summary['averageOrderValue'] as int;
    final paymentTotals = summary['paymentTotals'] as Map<String, int>;
    final paymentCounts = summary['paymentCounts'] as Map<String, int>;
    final topProducts = summary['topProducts'] as List<TopProductStat>;
    final lowStock = summary['lowStockProducts'] as List<ProductModel>;
    final txList = summary['filteredTransactions'] as List<TransactionModel>;

    final isThermal = paperFormat == 'Thermal80';
    final maxWidth = isThermal ? '320px' : '780px';
    final nowStr = CurrencyFormatter.formatDateTime(DateTime.now());
    final docCode =
        'RPT-${period.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch % 10000}';

    final topProductsRows = topProducts
        .map(
          (p) => '''
          <tr>
            <td><strong>${p.productName}</strong></td>
            <td style="text-align:center;">${p.totalQuantitySold} Unit</td>
            <td style="text-align:right;font-weight:700;color:#15803D;">${CurrencyFormatter.formatRupiah(p.totalRevenue)}</td>
          </tr>
        ''',
        )
        .join();

    final txRows = txList
        .map(
          (tx) => '''
          <tr>
            <td><strong>${tx.transactionCode}</strong><br><span style="font-size:11px;color:#64748B;">${CurrencyFormatter.formatDateTime(tx.createdAt)}</span></td>
            <td>${tx.customerName}</td>
            <td style="text-align:center;"><span class="badge">${tx.paymentMethod}</span></td>
            <td style="text-align:right;font-weight:700;">${CurrencyFormatter.formatRupiah(tx.total)}</td>
          </tr>
        ''',
        )
        .join();

    final lowStockRows = lowStock
        .map(
          (p) => '''
          <tr>
            <td><strong>${p.name}</strong></td>
            <td>${p.sku} • ${p.categoryName}</td>
            <td style="text-align:right;font-weight:700;color:#B45309;">Sisa ${p.stock} Unit</td>
          </tr>
        ''',
        )
        .join();

    return '''
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Laporan Bisnis $storeName - Periode $period</title>
  <style>
    * { box-sizing: border-box; font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; }
    body { margin: 0; padding: ${isThermal ? '10px' : '24px'}; background: #FFFFFF; color: #0F172A; }
    .sheet { max-width: $maxWidth; margin: 0 auto; border: 1px solid #E2E8F0; border-radius: 14px; padding: ${isThermal ? '14px' : '28px'}; }
    .header { display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid #153423; padding-bottom: 14px; margin-bottom: 18px; }
    .brand { font-size: ${isThermal ? '18px' : '24px'}; font-weight: 900; color: #153423; }
    .brand span { color: #F05A28; }
    .meta { font-size: 12px; color: #475569; line-height: 1.5; }
    .doc-badge { background: #ECFDF5; color: #15803D; border: 1px solid #86EFAC; padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 800; display: inline-block; margin-bottom: 6px; }
    .kpi-grid { display: grid; grid-template-columns: repeat(${isThermal ? '2' : '4'}, 1fr); gap: 10px; margin-bottom: 20px; }
    .kpi-card { background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 10px; padding: 12px; }
    .kpi-label { font-size: 11px; color: #64748B; font-weight: 600; }
    .kpi-val { font-size: ${isThermal ? '14px' : '17px'}; font-weight: 900; color: #0F172A; margin-top: 4px; }
    h3 { font-size: 14px; font-weight: 800; color: #153423; margin: 18px 0 8px 0; text-transform: uppercase; letter-spacing: 0.4px; }
    table { width: 100%; border-collapse: collapse; font-size: 12.5px; margin-bottom: 14px; }
    th { background: #F1F5F9; color: #334155; text-align: left; padding: 8px 10px; font-weight: 800; border-bottom: 1px solid #CBD5E1; }
    td { padding: 8px 10px; border-bottom: 1px solid #E2E8F0; vertical-align: middle; }
    .badge { background: #FFF7ED; color: #EA580C; border: 1px solid #FDBA74; padding: 2px 8px; border-radius: 10px; font-size: 10.5px; font-weight: 800; }
    .footer-sign { display: flex; justify-content: space-between; align-items: flex-end; margin-top: 28px; padding-top: 16px; border-top: 1px dashed #CBD5E1; }
    .stamp { border: 2px solid #16A34A; color: #16A34A; padding: 6px 14px; border-radius: 8px; font-weight: 900; font-size: 11px; letter-spacing: 1px; text-transform: uppercase; display: inline-block; transform: rotate(-3deg); }
    @media print {
      body { padding: 0; }
      .sheet { border: none; padding: 0; max-width: 100%; }
    }
  </style>
</head>
<body>
  <div class="sheet">
    <div class="header">
      <div>
        <div class="brand">CloudPOS<span>.</span></div>
        <div style="font-weight:800;font-size:14px;margin-top:2px;">$storeName</div>
        <div class="meta">$storeAddress<br>Telp/WA: $storePhone</div>
      </div>
      <div style="text-align:right;">
        <div class="doc-badge">LAPORAN PERIODE: ${period.toUpperCase()}</div>
        <div class="meta">No. Dokumen: <strong>$docCode</strong><br>Tanggal Cetak: $nowStr</div>
      </div>
    </div>

    <div class="kpi-grid">
      <div class="kpi-card">
        <div class="kpi-label">Total Pendapatan</div>
        <div class="kpi-val" style="color:#15803D;">${CurrencyFormatter.formatRupiah(totalRevenue)}</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-label">Total Transaksi</div>
        <div class="kpi-val">$totalTx Nota</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-label">Produk Terjual</div>
        <div class="kpi-val">$totalItems Unit</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-label">Rata-rata per Nota</div>
        <div class="kpi-val">${CurrencyFormatter.formatRupiah(avgOrder)}</div>
      </div>
    </div>

    ${includePaymentBreakdown ? '''
    <h3>Rincian Metode Pembayaran</h3>
    <table>
      <thead>
        <tr>
          <th>Metode Pembayaran</th>
          <th style="text-align:center;">Jumlah Transaksi</th>
          <th style="text-align:right;">Total Nominal</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><strong>QRIS Digital</strong></td>
          <td style="text-align:center;">${paymentCounts['QRIS'] ?? 0} Nota</td>
          <td style="text-align:right;font-weight:700;">${CurrencyFormatter.formatRupiah(paymentTotals['QRIS'] ?? 0)}</td>
        </tr>
        <tr>
          <td><strong>Cash / Tunai Kasir</strong></td>
          <td style="text-align:center;">${paymentCounts['Cash'] ?? 0} Nota</td>
          <td style="text-align:right;font-weight:700;">${CurrencyFormatter.formatRupiah(paymentTotals['Cash'] ?? 0)}</td>
        </tr>
        <tr>
          <td><strong>Transfer Bank</strong></td>
          <td style="text-align:center;">${paymentCounts['Transfer'] ?? 0} Nota</td>
          <td style="text-align:right;font-weight:700;">${CurrencyFormatter.formatRupiah(paymentTotals['Transfer'] ?? 0)}</td>
        </tr>
      </tbody>
    </table>
    ''' : ''}

    ${includeTopProducts && topProducts.isNotEmpty ? '''
    <h3>Daftar Produk Terlaris (Top Selling)</h3>
    <table>
      <thead>
        <tr>
          <th>Nama Produk UMKM</th>
          <th style="text-align:center;">Terjual</th>
          <th style="text-align:right;">Total Kontribusi</th>
        </tr>
      </thead>
      <tbody>
        $topProductsRows
      </tbody>
    </table>
    ''' : ''}

    ${includeTransactions && txList.isNotEmpty ? '''
    <h3>Riwayat Nota Transaksi ($period)</h3>
    <table>
      <thead>
        <tr>
          <th>Kode Nota & Waktu</th>
          <th>Pelanggan</th>
          <th style="text-align:center;">Metode</th>
          <th style="text-align:right;">Total Bayar</th>
        </tr>
      </thead>
      <tbody>
        $txRows
      </tbody>
    </table>
    ''' : ''}

    ${includeLowStock && lowStock.isNotEmpty ? '''
    <h3>Peringatan Stok Gudang Menipis (&lt;= 10 Unit)</h3>
    <table>
      <thead>
        <tr>
          <th>Nama Produk</th>
          <th>SKU & Kategori</th>
          <th style="text-align:right;">Sisa Stok</th>
        </tr>
      </thead>
      <tbody>
        $lowStockRows
      </tbody>
    </table>
    ''' : ''}

    ${includeSignature ? '''
    <div class="footer-sign">
      <div>
        <div class="stamp">✓ VERIFIED • CLOUDPOS UMKM</div>
        <div class="meta" style="margin-top:8px;">Dokumen ini dihasilkan otomatis secara real-time oleh sistem CloudPOS.</div>
      </div>
      <div style="text-align:center;min-width:160px;">
        <div class="meta">Disahkan Oleh,</div>
        <div style="height:38px;"></div>
        <div style="font-weight:900;font-size:13px;border-top:1px solid #0F172A;padding-top:4px;">$authorName</div>
        <div class="meta">Admin / Manajer Operasional</div>
      </div>
    </div>
    ''' : ''}
  </div>
</body>
</html>
''';
  }
}
