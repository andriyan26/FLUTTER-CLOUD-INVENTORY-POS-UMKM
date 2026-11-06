import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/custom_cached_image.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import 'product_form_screen.dart';

class ProductDetailSwipeScreen extends StatefulWidget {
  final ProductModel initialProduct;

  const ProductDetailSwipeScreen({
    super.key,
    required this.initialProduct,
  });

  @override
  State<ProductDetailSwipeScreen> createState() =>
      _ProductDetailSwipeScreenState();
}

class _ProductDetailSwipeScreenState extends State<ProductDetailSwipeScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  int _selectedGalleryImageIdx = 0;
  String _selectedSize = 'Medium';
  final Set<String> _favoriteIds = {};

  static const List<String> _sizeOptions = ['Small', 'Medium', 'Large'];

  @override
  void initState() {
    super.initState();
    final products = context.read<ProductProvider>().allProducts;
    final foundIdx =
        products.indexWhere((p) => p.id == widget.initialProduct.id);
    _currentIndex = foundIdx != -1 ? foundIdx : 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _calculateDynamicPrice(int basePrice) {
    if (_selectedSize == 'Small') {
      return (basePrice * 0.85).round();
    } else if (_selectedSize == 'Large') {
      return (basePrice * 1.20).round();
    }
    return basePrice;
  }

  List<Color> _getThemeForIndex(int index) {
    final themes = AppColors.detailSwipeThemes;
    return themes[index % themes.length];
  }

  Future<void> _confirmDeleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${product.name}" (SKU: ${product.sku}) secara permanen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final isAdmin = context.read<AuthProvider>().isAdmin;
    final ok = await context.read<ProductProvider>().deleteProduct(
          product.id,
          isAdmin: isAdmin,
        );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk "${product.name}" berhasil dihapus.'),
          backgroundColor: AppColors.loginPrimaryGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      final err =
          context.read<ProductProvider>().errorMessage ?? 'Gagal menghapus.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final products = productProvider.allProducts.isNotEmpty
        ? productProvider.allProducts
        : [widget.initialProduct];

    if (_currentIndex >= products.length) {
      _currentIndex = 0;
    }

    final activeProduct = products[_currentIndex];
    final themeColors = _getThemeForIndex(_currentIndex);
    final Color bgTop = themeColors[0];
    final Color bgBottom = themeColors[1];
    final Color accentColor = themeColors[2];
    final int activePrice = _calculateDynamicPrice(activeProduct.price);
    final bool isFav = _favoriteIds.contains(activeProduct.id);

    final galleryImages = activeProduct.images.isNotEmpty
        ? activeProduct.images
        : [activeProduct.primaryImage];
    final safeGalleryIdx =
        _selectedGalleryImageIdx < galleryImages.length
            ? _selectedGalleryImageIdx
            : 0;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.25),
            radius: 1.15,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            child: Column(
              children: [
                // 1. TOP BAR PERSIS VIDEO 3 (KONSEP LIHAT DETAIL BARANG.mp4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFrostedIconButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'What would you like to order today?',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeProduct.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAdmin) ...[
                          _buildFrostedIconButton(
                            icon: Icons.edit_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductFormScreen(
                                    existingProduct: activeProduct,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          _buildFrostedIconButton(
                            icon: Icons.delete_outline_rounded,
                            onTap: () => _confirmDeleteProduct(activeProduct),
                          ),
                          const SizedBox(width: 6),
                        ],
                        _buildFrostedIconButton(
                          icon: isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          iconColor:
                              isFav ? const Color(0xFFEF4444) : Colors.white,
                          onTap: () {
                            setState(() {
                              if (isFav) {
                                _favoriteIds.remove(activeProduct.id);
                              } else {
                                _favoriteIds.add(activeProduct.id);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 2. AREA SWIPE HORIZONTAL (PageView + Thumbnail + Indikator)
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: products.length,
                        onPageChanged: (idx) {
                          setState(() {
                            _currentIndex = idx;
                            _selectedGalleryImageIdx = 0;
                          });
                        },
                        itemBuilder: (context, index) {
                          final item = products[index];
                          final itemTheme = _getThemeForIndex(index);
                          final itemAccent = itemTheme[2];
                          final currentImg = (index == _currentIndex &&
                                  safeGalleryIdx < item.images.length)
                              ? item.images[safeGalleryIdx]
                              : item.primaryImage;

                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 6),
                                // Lingkaran Halo Bersinar + Foto Produk (Persis Video 3)
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 210,
                                      height: 210,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: itemAccent.withValues(
                                          alpha: 0.16,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: itemAccent.withValues(
                                              alpha: 0.24,
                                            ),
                                            blurRadius: 42,
                                            spreadRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 178,
                                      height: 178,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                      child: CustomProductImage(
                                        imageUrl: currentImg,
                                        width: 178,
                                        height: 178,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        fallbackLabel: item.name,
                                      ),
                                    ),
                                  ],
                                ),

                                // Thumbnail Galeri jika produk memiliki > 1 foto
                                if (item.images.length > 1) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      item.images.length,
                                      (imgIdx) {
                                        final selected =
                                            safeGalleryIdx == imgIdx;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedGalleryImageIdx = imgIdx;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: selected
                                                    ? itemAccent
                                                    : Colors.white30,
                                                width: selected ? 2 : 1,
                                              ),
                                            ),
                                            child: CustomProductImage(
                                              imageUrl: item.images[imgIdx],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 14),

                                // Nama Produk Besar (Espresso / Mocha / Latte style)
                                Text(
                                  item.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Subjudul Aksen: SKU & Status Ketersediaan
                                Text(
                                  '${item.sku} • ${item.stockStatusLabel} (${item.stock} unit)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: itemAccent,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Deskripsi Produk
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Tombol Geser Kiri / Kanan untuk Kemudahan Navigasi Desktop & Mobile
                      if (_currentIndex > 0)
                        Positioned(
                          left: 0,
                          top: 85,
                          child: _buildSwipeArrow(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                              );
                            },
                          ),
                        ),
                      if (_currentIndex < products.length - 1)
                        Positioned(
                          right: 0,
                          top: 85,
                          child: _buildSwipeArrow(
                            icon: Icons.arrow_forward_ios_rounded,
                            onTap: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // Indikator Titik Halaman (Swipe Indicator)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(products.length, (idx) {
                    final active = idx == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? accentColor
                            : Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),

                // 3. PILIHAN UKURAN / PAKET (Small / Medium / Large Persis Video 3)
                Row(
                  children: _sizeOptions.map((size) {
                    final isSelected = _selectedSize == size;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSize = size;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accentColor
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? accentColor
                                    : Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected
                                    ? (accentColor.computeLuminance() > 0.5
                                        ? Colors.black
                                        : Colors.white)
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // 4. DUA KARTU INFO FROSTED GLASS (Price & Score/Stock Persis Video 3)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFrostedMetricBox(
                          icon: Icons.local_cafe_rounded,
                          label: 'Price',
                          value: CurrencyFormatter.formatRupiah(activePrice),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFrostedMetricBox(
                          icon: Icons.star_rounded,
                          label: 'Score • Stok',
                          value: '4.9 • ${activeProduct.stock}',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 5. TOMBOL UTAMA "Confirm Selection" (Tambah ke Kasir POS) Persis Video 3
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: activeProduct.isOutOfStock
                        ? null
                        : () {
                            final err = context.read<CartProvider>().addToCart(
                                  activeProduct,
                                  quantity: 1,
                                  variant: _selectedSize,
                                  unitPriceOverride: activePrice,
                                );
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF111827),
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  err ??
                                      '${activeProduct.name} - $_selectedSize selected (Masuk Kasir)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: activeProduct.isOutOfStock
                              ? [Colors.grey, Colors.blueGrey]
                              : [
                                  Colors.white.withValues(alpha: 0.92),
                                  accentColor,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          activeProduct.isOutOfStock
                              ? 'Stok Habis'
                              : 'Confirm Selection • Tambah Kasir',
                          style: const TextStyle(
                            color: Color(0xFF1A0D06),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrostedIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildSwipeArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  Widget _buildFrostedMetricBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

