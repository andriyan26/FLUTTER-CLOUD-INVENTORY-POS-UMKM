import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/custom_cached_image.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';

class QuickAddProductSheet extends StatefulWidget {
  final ProductModel product;

  const QuickAddProductSheet({
    super.key,
    required this.product,
  });

  @override
  State<QuickAddProductSheet> createState() => _QuickAddProductSheetState();
}

class _QuickAddProductSheetState extends State<QuickAddProductSheet> {
  int _quantity = 1;
  bool _addedSuccess = false;
  String _selectedOption = 'Reguler';
  bool _extraPackaging = false;

  int get _unitPrice {
    int base = widget.product.price;
    if (_selectedOption == 'Paket Hemat (+2rb)') base += 2000;
    if (_extraPackaging) base += 1000;
    return base;
  }

  int get _totalPrice => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar & Header (Persis Video 2 detik 00:10)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chevron_left_rounded, size: 26),
                ),
                Expanded(
                  child: Text(
                    p.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDarkSlate,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),

            // Gambar Produk Tengah
            SizedBox(
              height: 135,
              width: 155,
              child: CustomProductImage(
                imageUrl: p.primaryImage,
                borderRadius: BorderRadius.circular(22),
                fallbackLabel: p.name,
              ),
            ),
            const SizedBox(height: 12),

            // Counter Besar "01" + Tombol '-' dan '+' Oranye + Pill Hitam Harga (Persis Video 2 detik 00:10)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol '-' Abu-abu
                Material(
                  color: const Color(0xFFF1F5F9),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.remove_rounded,
                        color: AppColors.textDarkSlate,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Text(
                      _quantity.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDarkSlate,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E242B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        CurrencyFormatter.formatRupiah(_totalPrice),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${CurrencyFormatter.formatRupiah(_unitPrice)} / unit • Stok: ${p.stock}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Tombol '+' Oranye
                Material(
                  color: AppColors.posOrange,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _quantity < p.stock
                        ? () => setState(() => _quantity++)
                        : null,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Pilihan Varian / Opsi Kasir (Persis Video 2 detik 00:12)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilihan Varian / Paket',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.posOrangeLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Opsional',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.posOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildOptionRadioRow('Reguler', '+Rp 0'),
                  _buildOptionRadioRow('Paket Hemat (+2rb)', '+Rp 2.000'),
                  CheckboxListTile(
                    value: _extraPackaging,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.posOrange,
                    title: const Text(
                      'Kemasan Kantong Ramah Lingkungan',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    secondary: const Text(
                      '+Rp 1.000',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _extraPackaging = val ?? false);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tombol Kapsul Oranye "Ajouter au panier / Tambah ke Kasir" dengan animasi Checkmark ✓ (Persis Video 2 detik 00:14)
            GestureDetector(
              onTap: () async {
                final err = context.read<CartProvider>().addToCart(
                      p,
                      quantity: _quantity,
                      variant: _selectedOption,
                      unitPriceOverride: _unitPrice,
                    );
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(err),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                  return;
                }
                setState(() => _addedSuccess = true);
                await Future.delayed(const Duration(milliseconds: 520));
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.posOrange, AppColors.posOrangeDark],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44F05A28),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _addedSuccess
                              ? 'Ditambahkan ke Kasir!'
                              : 'Tambah ke Kasir (POS)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatRupiah(_totalPrice),
                          style: const TextStyle(
                            color: Color(0xFFFFE4D6),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _addedSuccess
                            ? Icons.check_rounded
                            : Icons.shopping_basket_outlined,
                        color: AppColors.posOrange,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRadioRow(String label, String priceLabel) {
    final selected = _selectedOption == label;
    return InkWell(
      onTap: () => setState(() => _selectedOption = label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.posOrange : AppColors.textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              priceLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
