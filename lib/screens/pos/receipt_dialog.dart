import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/transaction_model.dart';

class ReceiptDialog extends StatelessWidget {
  final TransactionModel transaction;

  const ReceiptDialog({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ilustrasi Tas Belanja Oranye seperti "Lamma - Votre commande est en préparation" di Video 2 (00:16)
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF1EC), Color(0xFFFFE0D4)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_rounded,
                      size: 48,
                      color: AppColors.posOrange,
                    ),
                    Positioned(
                      right: 14,
                      top: 14,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.loginPrimaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Transaksi Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDarkSlate,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.transactionCode,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.posOrange,
                ),
              ),
              Text(
                CurrencyFormatter.formatDateTime(transaction.createdAt),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Info Pelanggan & Pembayaran
              _buildInfoRow('Pelanggan', transaction.customerName),
              _buildInfoRow('Metode Bayar', transaction.paymentMethod),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Daftar Item Belanja
              ...transaction.details.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDarkSlate,
                              ),
                            ),
                            Text(
                              '${item.quantity} x ${CurrencyFormatter.formatRupiah(item.price)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(item.subtotal),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Total Tagihan',
                CurrencyFormatter.formatRupiah(transaction.total),
                bold: true,
              ),
              _buildInfoRow(
                'Uang Diterima',
                CurrencyFormatter.formatRupiah(transaction.amountPaid),
              ),
              _buildInfoRow(
                'Kembalian',
                CurrencyFormatter.formatRupiah(transaction.changeAmount),
                valueColor: AppColors.loginPrimaryGreen,
                bold: true,
              ),

              const SizedBox(height: 18),

              // Tombol Cetak Struk & Kembali (Persis Video 2 detik 00:17)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Mencetak struk ${transaction.transactionCode}...',
                        ),
                        backgroundColor: AppColors.loginPrimaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.posOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text(
                    'Cetak Struk Kasir',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Kembali ke Kasir',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: bold ? AppColors.textDarkSlate : AppColors.textMuted,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              color: valueColor ?? AppColors.textDarkSlate,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

