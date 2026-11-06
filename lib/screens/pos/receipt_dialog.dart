import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/print_helper.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';

class ReceiptDialog extends StatefulWidget {
  final TransactionModel transaction;

  const ReceiptDialog({
    super.key,
    required this.transaction,
  });

  @override
  State<ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<ReceiptDialog> {
  String _paperSize = '80mm'; // '58mm', '80mm', 'Invoice'
  bool _isPrinting = false;
  bool _printedSuccessfully = false;

  String _buildReceiptHtml({
    required String storeName,
    required String storeAddress,
    required String storePhone,
    required String cashierName,
    required bool includePpn,
  }) {
    final tx = widget.transaction;
    final widthCss = _paperSize == '58mm'
        ? '240px'
        : (_paperSize == '80mm' ? '310px' : '480px');
    final ppnAmount = (tx.total * 0.11).round();

    final itemsRows = tx.details
        .map(
          (item) => '''
          <tr>
            <td style="padding:4px 0;">
              <div style="font-weight:700;">${item.productName}</div>
              <div style="font-size:11px;color:#64748B;">${item.quantity} x ${CurrencyFormatter.formatRupiah(item.price)}</div>
            </td>
            <td style="text-align:right;font-weight:700;vertical-align:top;padding:4px 0;">
              ${CurrencyFormatter.formatRupiah(item.subtotal)}
            </td>
          </tr>
        ''',
        )
        .join();

    return '''
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Struk ${tx.transactionCode} - $storeName</title>
  <style>
    * { box-sizing: border-box; font-family: 'Courier New', Courier, monospace; }
    body { margin: 0; padding: 14px; background: #FFFFFF; color: #0F172A; }
    .receipt { width: $widthCss; margin: 0 auto; border: 1px dashed #94A3B8; padding: 14px; border-radius: 8px; }
    .center { text-align: center; }
    .brand { font-size: 18px; font-weight: 900; font-family: 'Segoe UI', sans-serif; color: #153423; }
    .brand span { color: #F05A28; }
    .dashed { border-top: 1px dashed #64748B; margin: 8px 0; }
    table { width: 100%; border-collapse: collapse; font-size: 12px; }
    .row { display: flex; justify-content: space-between; font-size: 12px; margin: 3px 0; }
    .bold { font-weight: 900; }
    .stamp { border: 1.5px solid #16A34A; color: #16A34A; padding: 3px 10px; border-radius: 6px; font-size: 10px; font-weight: 900; display: inline-block; margin-top: 8px; }
    @media print {
      body { padding: 0; }
      .receipt { border: none; padding: 4px; }
    }
  </style>
</head>
<body>
  <div class="receipt">
    <div class="center">
      <div class="brand">CloudPOS<span>.</span></div>
      <div style="font-weight:800;font-size:12.5px;margin-top:2px;">$storeName</div>
      <div style="font-size:10.5px;color:#475569;">$storeAddress<br>WA: $storePhone</div>
    </div>
    <div class="dashed"></div>
    <div class="row"><span>No. Nota</span><span class="bold">${tx.transactionCode}</span></div>
    <div class="row"><span>Waktu</span><span>${CurrencyFormatter.formatDateTime(tx.createdAt)}</span></div>
    <div class="row"><span>Kasir</span><span>$cashierName</span></div>
    <div class="row"><span>Pelanggan</span><span>${tx.customerName}</span></div>
    <div class="row"><span>Metode</span><span class="bold">${tx.paymentMethod}</span></div>
    <div class="dashed"></div>
    <table>
      <tbody>
        $itemsRows
      </tbody>
    </table>
    <div class="dashed"></div>
    <div class="row"><span>Subtotal</span><span>${CurrencyFormatter.formatRupiah(tx.subtotal)}</span></div>
    ${includePpn ? '<div class="row"><span>PPN UMKM (11%)</span><span>${CurrencyFormatter.formatRupiah(ppnAmount)}</span></div>' : ''}
    <div class="row bold" style="font-size:13.5px;margin-top:4px;"><span>TOTAL TAGIHAN</span><span>${CurrencyFormatter.formatRupiah(tx.total)}</span></div>
    <div class="row"><span>Uang Diterima</span><span>${CurrencyFormatter.formatRupiah(tx.amountPaid)}</span></div>
    <div class="row bold" style="color:#15803D;"><span>Kembalian</span><span>${CurrencyFormatter.formatRupiah(tx.changeAmount)}</span></div>
    <div class="dashed"></div>
    <div class="center">
      <div class="stamp">✓ LUNAS • TERVERIFIKASI</div>
      <div style="font-size:10.5px;color:#475569;margin-top:8px;">Terima kasih telah berbelanja!<br>Simpan struk ini sebagai bukti transaksi sah.</div>
    </div>
  </div>
</body>
</html>
''';
  }

  String _buildWhatsAppReceiptText({
    required String storeName,
    required String storeAddress,
    required String cashierName,
  }) {
    final tx = widget.transaction;
    final sb = StringBuffer();
    sb.writeln('*STRUK DIGITAL CLOUDPOS*');
    sb.writeln('*$storeName*');
    sb.writeln(storeAddress);
    sb.writeln('--------------------------------');
    sb.writeln('No. Nota: *${tx.transactionCode}*');
    sb.writeln('Waktu: ${CurrencyFormatter.formatDateTime(tx.createdAt)}');
    sb.writeln('Kasir: $cashierName');
    sb.writeln('Pelanggan: ${tx.customerName}');
    sb.writeln('Metode: *${tx.paymentMethod}*');
    sb.writeln('--------------------------------');
    for (final item in tx.details) {
      sb.writeln(
        '• ${item.productName} (${item.quantity}x ${CurrencyFormatter.formatRupiah(item.price)}) = *${CurrencyFormatter.formatRupiah(item.subtotal)}*',
      );
    }
    sb.writeln('--------------------------------');
    sb.writeln('TOTAL TAGIHAN: *${CurrencyFormatter.formatRupiah(tx.total)}*');
    sb.writeln(
      'Uang Diterima: ${CurrencyFormatter.formatRupiah(tx.amountPaid)}',
    );
    sb.writeln('Kembalian: *${CurrencyFormatter.formatRupiah(tx.changeAmount)}*');
    sb.writeln('--------------------------------');
    sb.writeln('Status: *LUNAS ✓*');
    sb.writeln('_Terima kasih telah berbelanja!_');
    return sb.toString();
  }

  Future<void> _handlePrintReceipt(AuthProvider auth) async {
    final user = auth.currentUser;
    setState(() {
      _isPrinting = true;
      _printedSuccessfully = false;
    });

    final htmlDoc = _buildReceiptHtml(
      storeName: user?.storeName ?? 'CloudPOS • Cabang Utama UMKM',
      storeAddress:
          user?.storeAddress ?? 'Jl. Asia Afrika No. 88, Kota Bandung',
      storePhone: user?.phoneNumber ?? '+62 812-8899-2026',
      cashierName: user?.fullName.split(' ').first ?? 'Andriyan',
      includePpn: auth.enableTaxPpn,
    );

    await Future.delayed(const Duration(milliseconds: 350));
    await PrintHelper.printHtmlDocument(
      title: 'Struk_${widget.transaction.transactionCode}',
      htmlDocument: htmlDoc,
    );

    if (!mounted) return;
    setState(() {
      _isPrinting = false;
      _printedSuccessfully = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.loginPrimaryGreen,
        content: Text(
          'Struk ${widget.transaction.transactionCode} ($_paperSize) siap dicetak / disimpan PDF!',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Future<void> _handleCopyWhatsApp(AuthProvider auth) async {
    final user = auth.currentUser;
    final text = _buildWhatsAppReceiptText(
      storeName: user?.storeName ?? 'CloudPOS • Cabang Utama UMKM',
      storeAddress:
          user?.storeAddress ?? 'Jl. Asia Afrika No. 88, Kota Bandung',
      cashierName: user?.fullName.split(' ').first ?? 'Andriyan',
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.loginPrimaryGreen,
        content: Text(
          'Struk digital berhasil disalin untuk dikirim ke WhatsApp pelanggan!',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Future<void> _handleDownloadReceiptHtml(AuthProvider auth) async {
    final user = auth.currentUser;
    final htmlDoc = _buildReceiptHtml(
      storeName: user?.storeName ?? 'CloudPOS • Cabang Utama UMKM',
      storeAddress:
          user?.storeAddress ?? 'Jl. Asia Afrika No. 88, Kota Bandung',
      storePhone: user?.phoneNumber ?? '+62 812-8899-2026',
      cashierName: user?.fullName.split(' ').first ?? 'Andriyan',
      includePpn: auth.enableTaxPpn,
    );
    await PrintHelper.downloadFile(
      fileName: 'Struk_${widget.transaction.transactionCode}.html',
      content: htmlDoc,
      mimeType: 'text/html;charset=utf-8',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.loginPrimaryGreen,
        content: Text(
          'File Struk ${widget.transaction.transactionCode} berhasil diunduh!',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final tx = widget.transaction;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 760),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. HEADER BAR PILIH UKURAN KERTAS STRUK
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 10, 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              color: AppColors.posOrange,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Pratinjau & Cetak Struk Kasir',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDarkSlate,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _buildPaperSizeTab('58mm', 'Thermal 58mm'),
                          _buildPaperSizeTab('80mm', 'Thermal 80mm'),
                          _buildPaperSizeTab('Invoice', 'Nota Digital'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. KERTAS STRUK THERMAL REALISTIS DENGAN TEPI GERIGI
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(14),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: _paperSize == '58mm'
                          ? 275
                          : (_paperSize == '80mm' ? 325 : 350),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x180F172A),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tepi Atas Kertas Struk Bergerigi
                          CustomPaint(
                            size: const Size(double.infinity, 8),
                            painter: _SerratedPaperEdgePainter(isTop: true),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                            child: Column(
                              children: [
                                // Emblem Tas Belanja CloudPOS
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFF1EC),
                                        Color(0xFFFFE0D4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(
                                        Icons.shopping_bag_rounded,
                                        size: 34,
                                        color: AppColors.posOrange,
                                      ),
                                      Positioned(
                                        right: 9,
                                        top: 9,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: AppColors.loginPrimaryGreen,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Nama & Alamat Toko
                                if (auth.printStoreHeaderOnReceipt) ...[
                                  Text(
                                    user?.storeName ??
                                        'CloudPOS • Cabang Utama UMKM',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.loginHeaderDarkGreen,
                                    ),
                                  ),
                                  Text(
                                    user?.storeAddress ??
                                        'Jl. Asia Afrika No. 88, Kota Bandung',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    'WA: ${user?.phoneNumber ?? '+62 812-8899-2026'}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],

                                const Text(
                                  'Transaksi Berhasil!',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDarkSlate,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tx.transactionCode,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.posOrange,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatDateTime(
                                    tx.createdAt,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),

                                const SizedBox(height: 10),
                                _buildDashedDivider(),
                                const SizedBox(height: 8),

                                // Info Kasir, Pelanggan & Metode Bayar
                                _buildInfoRow(
                                  'Kasir Bertugas',
                                  user?.fullName.split(' ').first ?? 'Andriyan',
                                ),
                                _buildInfoRow('Pelanggan', tx.customerName),
                                _buildInfoRow('Metode Bayar', tx.paymentMethod),

                                const SizedBox(height: 8),
                                _buildDashedDivider(),
                                const SizedBox(height: 8),

                                // Daftar Item Belanja
                                ...tx.details.map(
                                  (item) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      AppColors.textDarkSlate,
                                                ),
                                              ),
                                              Text(
                                                '${item.quantity} x ${CurrencyFormatter.formatRupiah(item.price)}',
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.formatRupiah(
                                            item.subtotal,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textDarkSlate,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                _buildDashedDivider(),
                                const SizedBox(height: 8),

                                _buildInfoRow(
                                  'Subtotal',
                                  CurrencyFormatter.formatRupiah(tx.subtotal),
                                ),
                                if (auth.enableTaxPpn)
                                  _buildInfoRow(
                                    'PPN UMKM (11%)',
                                    CurrencyFormatter.formatRupiah(
                                      (tx.total * 0.11).round(),
                                    ),
                                  ),
                                _buildInfoRow(
                                  'TOTAL TAGIHAN',
                                  CurrencyFormatter.formatRupiah(tx.total),
                                  bold: true,
                                ),
                                _buildInfoRow(
                                  'Uang Diterima',
                                  CurrencyFormatter.formatRupiah(tx.amountPaid),
                                ),
                                _buildInfoRow(
                                  'Kembalian',
                                  CurrencyFormatter.formatRupiah(
                                    tx.changeAmount,
                                  ),
                                  valueColor: AppColors.loginPrimaryGreen,
                                  bold: true,
                                ),

                                const SizedBox(height: 10),
                                _buildDashedDivider(),
                                const SizedBox(height: 10),

                                // Stempel Lunas & Visual Barcode Struk
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.loginSoftMint,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.loginPrimaryGreen,
                                    ),
                                  ),
                                  child: const Text(
                                    '✓ LUNAS • TERVERIFIKASI CLOUDPOS',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.loginPrimaryGreen,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Simulasi Barcode Garis Vertikal
                                SizedBox(
                                  height: 26,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(28, (idx) {
                                      final w = (idx % 3 == 0)
                                          ? 3.0
                                          : ((idx % 2 == 0) ? 1.5 : 2.2);
                                      return Container(
                                        width: w,
                                        height: 24,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 1.2,
                                        ),
                                        color: AppColors.textDarkSlate,
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Terima kasih telah berbelanja di UMKM kami!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Tepi Bawah Kertas Struk Bergerigi
                          CustomPaint(
                            size: const Size(double.infinity, 8),
                            painter: _SerratedPaperEdgePainter(isTop: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. FOOTER TOMBOL CETAK STRUK, SALIN WA & UNDUH
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
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
                        onPressed: _isPrinting
                            ? null
                            : () => _handlePrintReceipt(auth),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _printedSuccessfully
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
                                _printedSuccessfully
                                    ? Icons.check_circle_rounded
                                    : Icons.print_rounded,
                                size: 18,
                              ),
                        label: Text(
                          _isPrinting
                              ? 'Mencetak Struk ($_paperSize)...'
                              : (_printedSuccessfully
                                  ? 'Cetak Ulang Struk ($_paperSize)'
                                  : 'Cetak Struk Kasir ($_paperSize) / PDF'),
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
                            onPressed: () => _handleCopyWhatsApp(auth),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            label: const Text(
                              'Salin Struk WA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleDownloadReceiptHtml(auth),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.download_rounded, size: 14),
                            label: const Text(
                              'Unduh Nota',
                              style: TextStyle(
                                fontSize: 11,
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

  Widget _buildPaperSizeTab(String id, String label) {
    final active = _paperSize == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _paperSize = id;
          _printedSuccessfully = false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.posOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : AppColors.textDarkSlate,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 7).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: 4,
              height: 1.2,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: bold ? AppColors.textDarkSlate : AppColors.textMuted,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: valueColor ?? AppColors.textDarkSlate,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SerratedPaperEdgePainter extends CustomPainter {
  final bool isTop;

  _SerratedPaperEdgePainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;

    const double toothWidth = 10.0;
    final int count = (size.width / toothWidth).ceil();
    final path = Path();

    if (isTop) {
      path.moveTo(0, 0);
      for (int i = 0; i < count; i++) {
        final x = i * toothWidth;
        path.lineTo(x + toothWidth / 2, size.height);
        path.lineTo(x + toothWidth, 0);
      }
      path.close();
    } else {
      path.moveTo(0, size.height);
      for (int i = 0; i < count; i++) {
        final x = i * toothWidth;
        path.lineTo(x + toothWidth / 2, 0);
        path.lineTo(x + toothWidth, size.height);
      }
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
