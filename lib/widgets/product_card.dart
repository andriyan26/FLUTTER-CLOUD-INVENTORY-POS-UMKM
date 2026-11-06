import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../core/widgets/custom_cached_image.dart';
import '../models/product_model.dart';

class ProductCard extends StatefulWidget {
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
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final Color statusColor = product.isOutOfStock
        ? AppColors.errorRed
        : (product.isLowStock
            ? AppColors.warningAmber
            : AppColors.loginPrimaryGreen);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTapDetail,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D0F172A),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Produk Bersih + Badge Status Stok
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomProductImage(
                        imageUrl: product.primaryImage,
                        borderRadius: BorderRadius.circular(18),
                        fallbackLabel: product.name,
                      ),
                    ),
                    // Badge Stok di Kiri Atas
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
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
                              'Stok ${product.stock}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Nama Produk Tebal (Persis Smash Burger / Pizza Pepperoni di Video 2)
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDarkSlate,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              // Baris Ikon Toko Oranye + Kategori / SKU (Persis Video 2)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      color: AppColors.posOrangeLight,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 10,
                      color: AppColors.posOrange,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '${product.categoryName} • ${product.sku}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Baris Bawah: Harga Rupiah Tebal + Tombol Bulat Oranye '+' (Persis Video 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      CurrencyFormatter.formatRupiah(product.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDarkSlate,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Material(
                    color: product.isOutOfStock
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFFFFEFE9),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap:
                          product.isOutOfStock ? null : widget.onTapAddToCart,
                      child: Padding(
                        padding: const EdgeInsets.all(7.5),
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
      ),
    );
  }
}
