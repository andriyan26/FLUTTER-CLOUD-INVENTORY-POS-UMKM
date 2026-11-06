import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../core/widgets/custom_cached_image.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTapDetail;
  final VoidCallback onTapAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTapDetail,
    required this.onTapAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = product.isOutOfStock
        ? AppColors.errorRed
        : (product.isLowStock
            ? AppColors.warningAmber
            : AppColors.loginPrimaryGreen);

    return GestureDetector(
      onTap: onTapDetail,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk + Badge Status Stok & Tombol Detail
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomProductImage(
                      imageUrl: product.primaryImage,
                      borderRadius: BorderRadius.circular(16),
                      fallbackLabel: product.name,
                    ),
                  ),
                  // Badge Stok di Kiri Atas
                  Positioned(
                    top: 7,
                    left: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.68),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.stockStatusLabel} (${product.stock})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tombol Cepat Lihat Detail (Swipe View)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: InkWell(
                      onTap: onTapDetail,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            // Nama Produk (Tebal seperti Smash Burger / Pizza Pepperoni di Video 2)
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textDarkSlate,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            // Baris SKU & Kategori (dengan ikon toko kecil seperti di Video 2)
            Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  size: 12,
                  color: AppColors.posOrange,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${product.sku} • ${product.categoryName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Baris Bawah: Harga Rupiah + Tombol Bulat Oranye '+' (Persis Video 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    CurrencyFormatter.formatRupiah(product.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDarkSlate,
                    ),
                  ),
                ),
                Material(
                  color: product.isOutOfStock
                      ? const Color(0xFFE2E8F0)
                      : AppColors.posOrangeLight,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: product.isOutOfStock ? null : onTapAddToCart,
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: product.isOutOfStock
                            ? AppColors.textMuted
                            : AppColors.posOrange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
