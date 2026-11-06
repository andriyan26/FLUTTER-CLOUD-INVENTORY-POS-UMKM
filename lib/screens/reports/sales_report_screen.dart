import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/print_helper.dart';
import '../../core/widgets/smooth_staggered_reveal.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/report_service.dart';
import '../../widgets/stat_card.dart';
import 'report_print_studio_dialog.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final ReportService _reportService = ReportService();
  String _selectedPeriod = 'Bulanan';

  void _openPrintReportStudio() {
    showDialog(
      context: context,
      builder: (_) => ReportPrintStudioDialog(initialPeriod: _selectedPeriod),
    );
  }

  void _showExportCsvDialog(List<TransactionModel> transactions) {
    final csvData = _reportService.generateCsv(transactions);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Export CSV Laporan ($_selectedPeriod)',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data CSV siap diunduh langsung ke perangkat atau disalin ke Excel / Google Sheets:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 10),
              Container(
                height: 150,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csvData,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF86EFAC),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.posOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await PrintHelper.downloadFile(
                fileName:
                    'Laporan_CloudPOS_${_selectedPeriod.toLowerCase()}.csv',
                content: csvData,
              );
              await Clipboard.setData(ClipboardData(text: csvData));
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.loginPrimaryGreen,
                  content: Text(
                    'File CSV $_selectedPeriod berhasil diunduh & disalin ke Clipboard!',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Unduh & Salin CSV'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final productProvider = context.watch<ProductProvider>();

    final summary = _reportService.buildReportSummary(
      transactions: txProvider.transactions,
      products: productProvider.allProducts,
      period: _selectedPeriod,
    );

    final int totalRevenue = summary['totalRevenue'] as int;
    final int totalTransactions = summary['totalTransactions'] as int;
    final int totalItemsSold = summary['totalItemsSold'] as int;
    final int avgOrderValue = summary['averageOrderValue'] as int;
    final Map<String, int> paymentTotals =
        summary['paymentTotals'] as Map<String, int>;
    final Map<String, int> paymentCounts =
        summary['paymentCounts'] as Map<String, int>;
    final List<TopProductStat> topProducts =
        summary['topProducts'] as List<TopProductStat>;
    final List<ProductModel> lowStockProducts =
        summary['lowStockProducts'] as List<ProductModel>;
    final List<TransactionModel> filteredTx =
        summary['filteredTransactions'] as List<TransactionModel>;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER ATAS + TOMBOL CETAK LAPORAN & CSV
              SmoothStaggeredReveal(
                index: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laporan Bisnis UMKM',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                          Text(
                            'Rekapitulasi penjualan harian, mingguan & bulanan',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => _showExportCsvDialog(filteredTx),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          tooltip: 'Export CSV / Excel',
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          onPressed: _openPrintReportStudio,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.posOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          icon: const Icon(Icons.print_rounded, size: 16),
                          label: const Text(
                            'Cetak',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // FILTER PERIODE SEGMENTED BAR (HARIAN / MINGGUAN / BULANAN / SEMUA)
              SmoothStaggeredReveal(
                index: 1,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children:
                        ['Harian', 'Mingguan', 'Bulanan', 'Semua'].map((p) {
                      final selected = _selectedPeriod == p;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPeriod = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.posOrange
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: selected
                                  ? const [
                                      BoxShadow(
                                        color: Color(0x33F05A28),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textDarkSlate,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 4 KARTU STATISTIK RINGKASAN PERIODE
              SmoothStaggeredReveal(
                key: ValueKey('kpi_grid_$_selectedPeriod'),
                index: 2,
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.1,
                  children: [
                    StatCard(
                      title: 'Total Pendapatan',
                      value: CurrencyFormatter.formatRupiah(totalRevenue),
                      subtitle: 'Periode $_selectedPeriod',
                      icon: Icons.account_balance_wallet_rounded,
                      accentColor: AppColors.loginPrimaryGreen,
                    ),
                    StatCard(
                      title: 'Total Transaksi',
                      value: '$totalTransactions Nota',
                      subtitle: '$totalItemsSold Unit Terjual',
                      icon: Icons.receipt_long_rounded,
                      accentColor: AppColors.posOrange,
                    ),
                    StatCard(
                      title: 'Rata-rata / Nota',
                      value: CurrencyFormatter.formatRupiah(avgOrderValue),
                      subtitle: 'Nilai Keranjang',
                      icon: Icons.trending_up_rounded,
                      accentColor: AppColors.primaryIndigo,
                    ),
                    StatCard(
                      title: 'Stok Menipis',
                      value: '${lowStockProducts.length} Produk',
                      subtitle: 'Perlu Restock (<=10)',
                      icon: Icons.warning_amber_rounded,
                      accentColor: AppColors.warningAmber,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // BANNER STUDIO CETAK LAPORAN RESMI (KLIK UNTUK PILIH HARIAN/BULANAN & PREVIEW KERTAS)
              SmoothStaggeredReveal(
                index: 3,
                child: InkWell(
                  onTap: _openPrintReportStudio,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF153423), Color(0xFF285B3A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26153423),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.print_rounded,
                            color: Color(0xFFBEF264),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cetak Laporan Resmi ($_selectedPeriod)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Text(
                                'Pilih Harian/Mingguan/Bulanan, Format A4/Thermal & Simpan PDF',
                                style: TextStyle(
                                  color: Color(0xFFD1FAE5),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Color(0xFFBEF264),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // RINCIAN METODE PEMBAYARAN (QRIS, CASH, TRANSFER)
              SmoothStaggeredReveal(
                key: ValueKey('pay_breakdown_$_selectedPeriod'),
                index: 4,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rincian Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPaymentMethodBar(
                        label: 'QRIS Digital',
                        count: paymentCounts['QRIS'] ?? 0,
                        amount: paymentTotals['QRIS'] ?? 0,
                        totalRevenue: totalRevenue,
                        color: AppColors.loginPrimaryGreen,
                      ),
                      const SizedBox(height: 8),
                      _buildPaymentMethodBar(
                        label: 'Cash / Tunai Kasir',
                        count: paymentCounts['Cash'] ?? 0,
                        amount: paymentTotals['Cash'] ?? 0,
                        totalRevenue: totalRevenue,
                        color: AppColors.posOrange,
                      ),
                      const SizedBox(height: 8),
                      _buildPaymentMethodBar(
                        label: 'Transfer Bank',
                        count: paymentCounts['Transfer'] ?? 0,
                        amount: paymentTotals['Transfer'] ?? 0,
                        totalRevenue: totalRevenue,
                        color: AppColors.primaryIndigo,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // PRODUK TERLARIS
              const SmoothStaggeredReveal(
                index: 5,
                child: Text(
                  'Produk Terlaris',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDarkSlate,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (topProducts.isEmpty)
                const Text(
                  'Belum ada data produk terjual pada periode ini.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                )
              else
                ...topProducts.asMap().entries.map(
                      (entry) => SmoothStaggeredReveal(
                        key: ValueKey(
                          'rep_tp_${entry.value.productName}_$_selectedPeriod',
                        ),
                        index: entry.key + 5,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.value.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    Text(
                                      '${entry.value.totalQuantitySold} unit terjual',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatRupiah(
                                  entry.value.totalRevenue,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                  color: AppColors.loginPrimaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 16),

              // LAPORAN STOK MENIPIS
              const SmoothStaggeredReveal(
                index: 8,
                child: Text(
                  'Laporan Stok Menipis (<= 10 Unit)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDarkSlate,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...lowStockProducts.asMap().entries.map(
                    (entry) => SmoothStaggeredReveal(
                      index: entry.key + 9,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                AppColors.warningAmber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.value.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'SKU: ${entry.value.sku} • ${entry.value.categoryName}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Sisa ${entry.value.stock}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodBar({
    required String label,
    required int count,
    required int amount,
    required int totalRevenue,
    required Color color,
  }) {
    final ratio =
        totalRevenue > 0 ? (amount / totalRevenue).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label ($count Nota)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDarkSlate,
              ),
            ),
            Text(
              CurrencyFormatter.formatRupiah(amount),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
