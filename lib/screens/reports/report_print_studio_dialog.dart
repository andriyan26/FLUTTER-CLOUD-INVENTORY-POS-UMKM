import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/print_helper.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/report_service.dart';

class ReportPrintStudioDialog extends StatefulWidget {
  final String initialPeriod;

  const ReportPrintStudioDialog({
    super.key,
    required this.initialPeriod,
  });

  @override
  State<ReportPrintStudioDialog> createState() =>
      _ReportPrintStudioDialogState();
}

class _ReportPrintStudioDialogState extends State<ReportPrintStudioDialog> {
  final ReportService _reportService = ReportService();

  late String _selectedPeriod;
  String _paperFormat = 'A4'; // 'A4' atau 'Thermal80'
  bool _includePaymentBreakdown = true;
  bool _includeTopProducts = true;
  bool _includeTransactions = true;
  bool _includeLowStock = true;
  bool _includeSignature = true;

  bool _isPrinting = false;
  bool _printSuccess = false;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
  }

  Future<void> _executePrint(Map<String, dynamic> summary) async {
    final user = context.read<AuthProvider>().currentUser;
    setState(() {
      _isPrinting = true;
      _printSuccess = false;
    });

    final htmlDoc = _reportService.generatePrintableReportHtml(
      period: _selectedPeriod,
      paperFormat: _paperFormat,
      storeName: user?.storeName ?? 'CloudPOS • Cabang Utama UMKM',
      storeAddress: user?.storeAddress ?? 'Jl. Asia Afrika No. 88, Bandung',
      storePhone: user?.phoneNumber ?? '+62 812-8899-2026',
      authorName: user?.fullName ?? 'Andriyan (Admin UMKM)',
      summary: summary,
      includePaymentBreakdown: _includePaymentBreakdown,
      includeTopProducts: _includeTopProducts,
      includeTransactions: _includeTransactions,
      includeLowStock: _includeLowStock,
      includeSignature: _includeSignature,
    );

    await Future.delayed(const Duration(milliseconds: 350));
    await PrintHelper.printHtmlDocument(
      title: 'Laporan_CloudPOS_$_selectedPeriod',
      htmlDocument: htmlDoc,
    );

    if (!mounted) return;
    setState(() {
      _isPrinting = false;
      _printSuccess = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.loginPrimaryGreen,
        content: Text(
          'Dokumen Laporan $_selectedPeriod ($_paperFormat) siap dicetak / disimpan sebagai PDF!',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Future<void> _downloadCsv(List<TransactionModel> txList) async {
    final csv = _reportService.generateCsv(txList);
    await PrintHelper.downloadFile(
      fileName: 'Laporan_CloudPOS_${_selectedPeriod.toLowerCase()}.csv',
      content: csv,
    );
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.loginPrimaryGreen,
        content: Text(
          'File CSV periode $_selectedPeriod berhasil diunduh & disalin!',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Future<void> _copyWhatsAppSummary(Map<String, dynamic> summary) async {
    final user = context.read<AuthProvider>().currentUser;
    final text = _reportService.generateWhatsAppSummary(
      period: _selectedPeriod,
      storeName: user?.storeName ?? 'CloudPOS • Cabang Utama UMKM',
      authorName: user?.fullName ?? 'Andriyan',
      summary: summary,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.loginPrimaryGreen,
        content: Text(
          'Ringkasan Laporan $_selectedPeriod berhasil disalin untuk WhatsApp!',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final productProvider = context.watch<ProductProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    final summary = _reportService.buildReportSummary(
      transactions: txProvider.transactions,
      products: productProvider.allProducts,
      period: _selectedPeriod,
    );

    final int totalRevenue = summary['totalRevenue'] as int;
    final int totalTx = summary['totalTransactions'] as int;
    final int totalItems = summary['totalItemsSold'] as int;
    final int avgOrder = summary['averageOrderValue'] as int;
    final paymentTotals = summary['paymentTotals'] as Map<String, int>;
    final paymentCounts = summary['paymentCounts'] as Map<String, int>;
    final topProducts = summary['topProducts'] as List<TopProductStat>;
    final lowStock = summary['lowStockProducts'] as List<ProductModel>;
    final filteredTx = summary['filteredTransactions'] as List<TransactionModel>;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 780),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. HEADER STUDIO CETAK LAPORAN
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF153423), Color(0xFF245336)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.print_rounded,
                        color: Color(0xFFBEF264),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Studio Cetak Laporan UMKM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Pilih periode Harian/Bulanan & kustomisasi isi dokumen',
                            style: TextStyle(
                              color: Color(0xFFD1FAE5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. KONTROL KONFIGURASI & PRATINJAU KERTAS LIVE
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A. PILIH PERIODE LAPORAN (HARIAN / MINGGUAN / BULANAN / SEMUA)
                      const Text(
                        '1. Pilih Periode Laporan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: ['Harian', 'Mingguan', 'Bulanan', 'Semua']
                              .map((period) {
                            final active = _selectedPeriod == period;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _selectedPeriod = period;
                                  _printSuccess = false;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? AppColors.posOrange
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: active
                                        ? const [
                                            BoxShadow(
                                              color: Color(0x33F05A28),
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    period,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: active
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

                      const SizedBox(height: 12),

                      // B. PILIH FORMAT KERTAS (A4 EKSEKUTIF vs THERMAL 80MM)
                      const Text(
                        '2. Pilih Ukuran & Format Kertas',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormatOption(
                              id: 'A4',
                              title: 'Dokumen A4 Resmi',
                              subtitle: 'Standar PDF & Printer',
                              icon: Icons.description_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFormatOption(
                              id: 'Thermal80',
                              title: 'Struk Rekap 80mm',
                              subtitle: 'Printer Kasir Thermal',
                              icon: Icons.receipt_long_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // C. PILIH KOMPONEN YANG IKUT DICETAK
                      const Text(
                        '3. Komponen Laporan yang Dicetak',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildToggleChip(
                            label: 'Metode Bayar',
                            selected: _includePaymentBreakdown,
                            onTap: () => setState(
                              () => _includePaymentBreakdown =
                                  !_includePaymentBreakdown,
                            ),
                          ),
                          _buildToggleChip(
                            label: 'Produk Terlaris',
                            selected: _includeTopProducts,
                            onTap: () => setState(
                              () => _includeTopProducts = !_includeTopProducts,
                            ),
                          ),
                          _buildToggleChip(
                            label: 'Daftar Nota ($totalTx)',
                            selected: _includeTransactions,
                            onTap: () => setState(
                              () =>
                                  _includeTransactions = !_includeTransactions,
                            ),
                          ),
                          _buildToggleChip(
                            label: 'Stok Menipis (${lowStock.length})',
                            selected: _includeLowStock,
                            onTap: () => setState(
                              () => _includeLowStock = !_includeLowStock,
                            ),
                          ),
                          _buildToggleChip(
                            label: 'Stempel & TTD',
                            selected: _includeSignature,
                            onTap: () => setState(
                              () => _includeSignature = !_includeSignature,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // D. PRATINJAU KERTAS LAPORAN SECARA LIVE (PAPER PREVIEW)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pratinjau Kertas Laporan (Live Preview)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.loginSoftMint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Format $_paperFormat • $_selectedPeriod',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.loginPrimaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // KERTAS DOKUMEN RESMI
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: _paperFormat == 'Thermal80' ? 16 : 0,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140F172A),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kop Dokumen Toko
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: const TextSpan(
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'CloudPOS',
                                              style: TextStyle(
                                                color: Color(0xFF153423),
                                              ),
                                            ),
                                            TextSpan(
                                              text: '.',
                                              style: TextStyle(
                                                color: AppColors.posOrange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        user?.storeName ??
                                            'CloudPOS • Cabang Utama UMKM',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textDarkSlate,
                                        ),
                                      ),
                                      Text(
                                        user?.storeAddress ??
                                            'Jl. Asia Afrika No. 88, Bandung',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF153423),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'LAPORAN ${_selectedPeriod.toUpperCase()}',
                                    style: const TextStyle(
                                      color: Color(0xFFBEF264),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(
                              height: 1,
                              thickness: 1.2,
                              color: Color(0xFF153423),
                            ),
                            const SizedBox(height: 10),

                            // 4 Kotak Ringkasan Eksekutif
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPaperKpiBox(
                                    'Total Omzet',
                                    CurrencyFormatter.formatRupiah(
                                      totalRevenue,
                                    ),
                                    valueColor: AppColors.loginPrimaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildPaperKpiBox(
                                    'Total Nota',
                                    '$totalTx Transaksi ($totalItems Item)',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPaperKpiBox(
                                    'Rata-rata / Nota',
                                    CurrencyFormatter.formatRupiah(avgOrder),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildPaperKpiBox(
                                    'Status Keuangan',
                                    '100% Lunas Terverifikasi',
                                    valueColor: AppColors.posOrange,
                                  ),
                                ),
                              ],
                            ),

                            if (_includePaymentBreakdown) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'RINCIAN METODE PEMBAYARAN',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF153423),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildPaperRow(
                                'QRIS Digital (${paymentCounts['QRIS'] ?? 0} Nota)',
                                CurrencyFormatter.formatRupiah(
                                  paymentTotals['QRIS'] ?? 0,
                                ),
                              ),
                              _buildPaperRow(
                                'Cash / Tunai (${paymentCounts['Cash'] ?? 0} Nota)',
                                CurrencyFormatter.formatRupiah(
                                  paymentTotals['Cash'] ?? 0,
                                ),
                              ),
                              _buildPaperRow(
                                'Transfer Bank (${paymentCounts['Transfer'] ?? 0} Nota)',
                                CurrencyFormatter.formatRupiah(
                                  paymentTotals['Transfer'] ?? 0,
                                ),
                              ),
                            ],

                            if (_includeTopProducts &&
                                topProducts.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'PRODUK TERLARIS (TOP SELLING)',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF153423),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...topProducts.take(5).map(
                                    (p) => _buildPaperRow(
                                      '${p.productName} (${p.totalQuantitySold} unit)',
                                      CurrencyFormatter.formatRupiah(
                                        p.totalRevenue,
                                      ),
                                      boldRight: true,
                                    ),
                                  ),
                            ],

                            if (_includeTransactions &&
                                filteredTx.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'DAFTAR NOTA TRANSAKSI (${filteredTx.length})',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF153423),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...filteredTx.take(5).map(
                                    (tx) => _buildPaperRow(
                                      '${tx.transactionCode} • ${tx.customerName} (${tx.paymentMethod})',
                                      CurrencyFormatter.formatRupiah(tx.total),
                                    ),
                                  ),
                            ],

                            if (_includeLowStock && lowStock.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'PERINGATAN STOK MENIPIS (<= 10 UNIT)',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFB45309),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...lowStock.take(4).map(
                                    (p) => _buildPaperRow(
                                      '${p.name} (${p.sku})',
                                      'Sisa ${p.stock} Unit',
                                      rightColor: const Color(0xFFB45309),
                                    ),
                                  ),
                            ],

                            if (_includeSignature) ...[
                              const SizedBox(height: 14),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Transform.rotate(
                                    angle: -0.05,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.loginPrimaryGreen,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '✓ VERIFIED • CLOUDPOS',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.loginPrimaryGreen,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Disahkan Oleh,',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        user?.fullName ?? 'Andriyan',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. FOOTER TOMBOL AKSI CETAK & EKSPOR
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isPrinting ? null : () => _executePrint(summary),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _printSuccess
                              ? AppColors.loginPrimaryGreen
                              : AppColors.posOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: _isPrinting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _printSuccess
                                    ? Icons.check_circle_rounded
                                    : Icons.print_rounded,
                                size: 18,
                              ),
                        label: Text(
                          _isPrinting
                              ? 'Menyiapkan Dokumen Cetak...'
                              : (_printSuccess
                                  ? 'Cetak Ulang Laporan $_selectedPeriod ($_paperFormat)'
                                  : 'Cetak Laporan $_selectedPeriod ($_paperFormat) / PDF'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _downloadCsv(filteredTx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.download_rounded, size: 15),
                            label: const Text(
                              'Unduh CSV / Excel',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyWhatsAppSummary(summary),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.share_outlined, size: 15),
                            label: const Text(
                              'Salin Teks WA',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _paperFormat == id;
    return GestureDetector(
      onTap: () => setState(() => _paperFormat = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.posOrangeLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.posOrange : AppColors.borderLight,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.posOrange : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.posOrangeDark
                          : AppColors.textDarkSlate,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.loginSoftMint : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected ? AppColors.loginPrimaryGreen : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 13,
              color: selected
                  ? AppColors.loginPrimaryGreen
                  : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: selected
                    ? AppColors.loginHeaderDarkGreen
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperKpiBox(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: valueColor ?? AppColors.textDarkSlate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperRow(
    String left,
    String right, {
    bool boldRight = false,
    Color? rightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textDarkSlate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            right,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: boldRight ? FontWeight.w900 : FontWeight.w700,
              color: rightColor ?? AppColors.textDarkSlate,
            ),
          ),
        ],
      ),
    );
  }
}

