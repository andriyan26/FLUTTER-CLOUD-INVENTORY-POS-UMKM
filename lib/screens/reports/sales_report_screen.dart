import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/smooth_staggered_reveal.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/report_service.dart';
import '../../widgets/stat_card.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final ReportService _reportService = ReportService();
  String _selectedPeriod = 'Bulanan';

  void _showExportCsvDialog(List<TransactionModel> transactions) {
    final csvData = _reportService.generateCsv(transactions);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export CSV Laporan Penjualan'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data CSV siap diunduh atau disalin ke Excel / Google Sheets:',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
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
              backgroundColor: AppColors.loginPrimaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvData));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data CSV berhasil disalin ke Clipboard!'),
                  backgroundColor: AppColors.loginPrimaryGreen,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Salin CSV'),
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
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmoothStaggeredReveal(
                index: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Laporan Bisnis UMKM',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDarkSlate,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => _showExportCsvDialog(filteredTx),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          tooltip: 'Export CSV',
                        ),
                        const SizedBox(width: 6),
                        IconButton.filled(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Menyiapkan cetak laporan periode $_selectedPeriod...',
                                ),
                                backgroundColor: AppColors.loginPrimaryGreen,
                              ),
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.posOrange,
                          ),
                          icon: const Icon(Icons.print_rounded, size: 18),
                          tooltip: 'Cetak Laporan',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              SmoothStaggeredReveal(
                index: 1,
                child: Row(
                  children:
                      ['Harian', 'Mingguan', 'Bulanan', 'Semua'].map((p) {
                    final selected = _selectedPeriod == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          p,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? Colors.white
                                : AppColors.textDarkSlate,
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppColors.posOrange,
                        onSelected: (_) => setState(() => _selectedPeriod = p),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              SmoothStaggeredReveal(
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
                      subtitle: 'Transaksi Lunas',
                      icon: Icons.receipt_long_rounded,
                      accentColor: AppColors.posOrange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const SmoothStaggeredReveal(
                index: 3,
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
                        index: entry.key + 4,
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

              const SmoothStaggeredReveal(
                index: 7,
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
                      index: entry.key + 8,
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
                            Column(
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
}
