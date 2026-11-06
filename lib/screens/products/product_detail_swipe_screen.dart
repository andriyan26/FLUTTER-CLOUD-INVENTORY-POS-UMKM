import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/cloud_pos_brand_logo.dart';
import '../../core/widgets/custom_cached_image.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import 'product_form_screen.dart';

/// Halaman Detail Produk Interaktif 3D Luxury Studio Medallion & 3D Coverflow Swipe
/// Mengikuti secara presisi VIDEO 3 (KONSEP LIHAT DETAIL BARANG.mp4 detik 00:00 - 00:21):
/// - Gambar produk 100% UTUH, TAJAM & JERNIH (`assets/produk/*.jpg`) tanpa ada bagian yang hilang/geripis,
///   dibingkai dalam "3D Floating Luxury Studio Medallion" berlapis kaca specular + cincin emas berputar.
/// - Animasi 3D Coverflow Perspective (`Matrix4.rotateY`) saat di-swipe ke kiri/kanan.
/// - Animasi Cincin Orbit Kembar + Partikel Bintang Emas di sekeliling luar pedestal (tidak menutupi foto produk).
/// - Interaksi tombol ukuran `Small`, `Medium`, `Large` dengan efek gelombang kejut (shockwave ring)
///   dan perubahan skala 3D (`0.85x`, `1.00x`, `1.14x`) serta harga secara real-time.
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

class _ProductDetailSwipeScreenState extends State<ProductDetailSwipeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late final AnimationController _orbitAndFloatController;
  late final AnimationController _pulseController;
  late final AnimationController _sizePulseWaveController;

  double _currentPageValue = 0.0;
  int _currentIndex = 0;
  String _selectedSize = 'Medium';
  String _activeCategoryFilter = '';
  final Set<String> _favoriteIds = {};

  static const List<String> _sizeOptions = ['Small', 'Medium', 'Large'];

  @override
  void initState() {
    super.initState();
    _activeCategoryFilter = widget.initialProduct.categoryName;

    final filtered = _getFilteredProducts(
      context.read<ProductProvider>().allProducts,
      _activeCategoryFilter,
    );
    final foundIdx =
        filtered.indexWhere((p) => p.id == widget.initialProduct.id);
    _currentIndex = foundIdx != -1 ? foundIdx : 0;
    _currentPageValue = _currentIndex.toDouble();

    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.76,
    )..addListener(_onPageScroll);

    // Controller 60fps untuk cincin orbit kembar, levitasi 3D & kilau kaca medali
    _orbitAndFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6400),
    )..repeat();

    // Controller denyut lembut halo spotlight di belakang produk
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Controller gelombang kejut (shockwave ring) saat ukuran Small/Medium/Large dipilih
    _sizePulseWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  void _onPageScroll() {
    if (!mounted || !_pageController.hasClients) return;
    setState(() {
      _currentPageValue = _pageController.page ?? _currentIndex.toDouble();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _orbitAndFloatController.dispose();
    _pulseController.dispose();
    _sizePulseWaveController.dispose();
    super.dispose();
  }

  List<ProductModel> _getFilteredProducts(
    List<ProductModel> allProducts,
    String categoryFilter,
  ) {
    if (categoryFilter.isEmpty || categoryFilter == 'Semua') {
      return allProducts;
    }
    final list = allProducts
        .where(
          (p) => p.categoryName.toLowerCase() == categoryFilter.toLowerCase(),
        )
        .toList();
    return list.isNotEmpty ? list : allProducts;
  }

  void _switchCategoryFilter(
    String newCategory,
    List<ProductModel> allProducts,
  ) {
    if (_activeCategoryFilter == newCategory) return;
    setState(() {
      _activeCategoryFilter = newCategory;
      _currentIndex = 0;
      _currentPageValue = 0.0;
      _selectedSize = 'Medium';
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _sizePulseWaveController.forward(from: 0.0);
  }

  int _calculateDynamicPrice(int basePrice) {
    if (_selectedSize == 'Small') {
      return (basePrice * 0.85).round();
    } else if (_selectedSize == 'Large') {
      return (basePrice * 1.20).round();
    }
    return basePrice;
  }

  double _getSizeScaleFactor() {
    switch (_selectedSize) {
      case 'Small':
        return 0.85;
      case 'Large':
        return 1.14;
      default:
        return 1.00;
    }
  }

  /// Palet warna studio spotlight dinamis berdasarkan kategori produk
  _StudioPalette _getPaletteForCategory(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('minum') || lower.contains('kopi')) {
      return const _StudioPalette(
        bgTop: Color(0xFF23120B),
        bgCenter: Color(0xFF4E2712),
        bgBottom: Color(0xFF120905),
        haloPrimary: Color(0xFFE07A38),
        haloSecondary: Color(0xFFFBBF24),
        accentButton: Color(0xFFD97736),
        rimLight: Color(0xFFFFDBA8),
      );
    } else if (lower.contains('makan') || lower.contains('kuliner')) {
      return const _StudioPalette(
        bgTop: Color(0xFF28100E),
        bgCenter: Color(0xFF5A1F17),
        bgBottom: Color(0xFF140706),
        haloPrimary: Color(0xFFEF5B2A),
        haloSecondary: Color(0xFFFBBF24),
        accentButton: Color(0xFFEA580C),
        rimLight: Color(0xFFFDE68A),
      );
    } else if (lower.contains('roti') || lower.contains('pastry')) {
      return const _StudioPalette(
        bgTop: Color(0xFF102229),
        bgCenter: Color(0xFF1E3F4C),
        bgBottom: Color(0xFF081216),
        haloPrimary: Color(0xFF38BDF8),
        haloSecondary: Color(0xFFFBBF24),
        accentButton: Color(0xFF0284C7),
        rimLight: Color(0xFFBAE6FD),
      );
    } else if (lower.contains('cemilan') || lower.contains('snack')) {
      return const _StudioPalette(
        bgTop: Color(0xFF26170A),
        bgCenter: Color(0xFF523214),
        bgBottom: Color(0xFF140C05),
        haloPrimary: Color(0xFFF59E0B),
        haloSecondary: Color(0xFFFB923C),
        accentButton: Color(0xFFD97706),
        rimLight: Color(0xFFFEF08A),
      );
    } else if (lower.contains('sembako')) {
      return const _StudioPalette(
        bgTop: Color(0xFF0D2118),
        bgCenter: Color(0xFF18422F),
        bgBottom: Color(0xFF07130E),
        haloPrimary: Color(0xFF10B981),
        haloSecondary: Color(0xFFFBBF24),
        accentButton: Color(0xFF059669),
        rimLight: Color(0xFFA7F3D0),
      );
    }
    return const _StudioPalette(
      bgTop: Color(0xFF111827),
      bgCenter: Color(0xFF1E293B),
      bgBottom: Color(0xFF090D16),
      haloPrimary: Color(0xFF60A5FA),
      haloSecondary: Color(0xFF38BDF8),
      accentButton: Color(0xFF2563EB),
      rimLight: Color(0xFFBFDBFE),
    );
  }

  Future<void> _confirmDeleteProduct(
    BuildContext context,
    ProductModel product,
  ) async {
    final isAdmin = context.read<AuthProvider>().isAdmin;
    final productProvider = context.read<ProductProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Produk?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${product.name}" dari inventaris?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.white60),
            ),
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

    if (confirmed == true && mounted) {
      final ok = await productProvider.deleteProduct(
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final allProducts = productProvider.allProducts;

    if (allProducts.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A0F0A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Tidak ada produk untuk ditampilkan.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final products = _getFilteredProducts(allProducts, _activeCategoryFilter);
    final safeIdx = _currentIndex.clamp(0, products.length - 1);
    final currentProduct = products[safeIdx];
    final palette = _getPaletteForCategory(currentProduct.categoryName);
    final dynamicPrice = _calculateDynamicPrice(currentProduct.price);
    final isFav = _favoriteIds.contains(currentProduct.id);

    final categories = <String>[
      'Minuman',
      'Makanan',
      'Roti',
      'Cemilan',
      'Sembako',
      'Kebutuhan',
      'Semua',
    ];

    return Scaffold(
      backgroundColor: palette.bgBottom,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.20),
            radius: 1.08,
            colors: [
              palette.bgCenter,
              palette.bgTop,
              palette.bgBottom,
            ],
            stops: const [0.0, 0.56, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  // =========================================================
                  // 1. TOP BAR: Tombol Back, Logo Ciri Khas CloudPOS & Aksi
                  // =========================================================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Row(
                      children: [
                        _buildGlassCircleIconButton(
                          icon: Icons.chevron_left_rounded,
                          tooltip: 'Kembali',
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        const CloudPosEmblemIcon(
                          size: 34,
                          animate: true,
                          showCrownBadge: false,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CloudPOS • Katalog Signature',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: palette.rimLight.withValues(alpha: 0.85),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 1),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                child: Text(
                                  currentProduct.categoryName,
                                  key: ValueKey(currentProduct.categoryName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isAdmin) ...[
                          _buildGlassCircleIconButton(
                            icon: Icons.edit_outlined,
                            tooltip: 'Edit Produk',
                            iconSize: 17,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductFormScreen(
                                    existingProduct: currentProduct,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          _buildGlassCircleIconButton(
                            icon: Icons.delete_outline_rounded,
                            tooltip: 'Hapus Produk',
                            iconSize: 17,
                            onTap: () => _confirmDeleteProduct(
                              context,
                              currentProduct,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        _buildGlassCircleIconButton(
                          icon: isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          iconColor:
                              isFav ? const Color(0xFFFF4D6D) : Colors.white,
                          tooltip: 'Favorit',
                          iconSize: 18,
                          onTap: () {
                            setState(() {
                              if (isFav) {
                                _favoriteIds.remove(currentProduct.id);
                              } else {
                                _favoriteIds.add(currentProduct.id);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // =========================================================
                  // 2. KATEGORI QUICK-SWITCHER PILLS (6 Kategori + Semua)
                  // =========================================================
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, idx) {
                        final cat = categories[idx];
                        final isSelected = _activeCategoryFilter.toLowerCase() ==
                                cat.toLowerCase() ||
                            (_activeCategoryFilter.isEmpty && cat == 'Semua');
                        return GestureDetector(
                          onTap: () => _switchCategoryFilter(cat, allProducts),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? palette.accentButton
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.35)
                                    : Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat == 'Semua' ? 'Semua (60)' : cat,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.72),
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // =========================================================
                  // 3. PANGGUNG 3D LUXURY STUDIO MEDALLION + ORBIT EMAS 60FPS
                  //    Foto produk 100% UTUH & JERNIH dengan bingkai 3D kaca mewah!
                  // =========================================================
                  Expanded(
                    flex: 6,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // A. Cincin Orbit Kembar, Halo Spotlight & Partikel Bintang di LUAR Medali
                        //    (Tidak pernah menutupi permukaan foto makanan/produk!)
                        IgnorePointer(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _orbitAndFloatController,
                              _pulseController,
                              _sizePulseWaveController,
                            ]),
                            builder: (context, _) {
                              return CustomPaint(
                                size: const Size(310, 310),
                                painter: _LuxuryOrbitalStagePainter(
                                  orbitPhase: _orbitAndFloatController.value,
                                  pulseValue: _pulseController.value,
                                  shockwaveValue:
                                      _sizePulseWaveController.value,
                                  primaryColor: palette.haloPrimary,
                                  secondaryColor: palette.haloSecondary,
                                  rimLightColor: palette.rimLight,
                                ),
                              );
                            },
                          ),
                        ),

                        // B. Carousel Swipe 3D Coverflow Perspective
                        PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: products.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                            _sizePulseWaveController.forward(from: 0.0);
                          },
                          itemBuilder: (context, index) {
                            final item = products[index];
                            final delta = (index - _currentPageValue);
                            final absDelta = delta.abs().clamp(0.0, 1.5);

                            // Skala parallax 3D saat di-swipe + skala ukuran Small/Medium/Large
                            final parallaxScale =
                                (1.0 - (absDelta * 0.26)).clamp(0.70, 1.0);
                            final activeSizeScale =
                                index == safeIdx ? _getSizeScaleFactor() : 0.88;
                            final totalScale = parallaxScale * activeSizeScale;

                            // Rotasi perspektif 3D Coverflow
                            final rotateY = (delta * -0.42).clamp(-0.65, 0.65);
                            final verticalShift = absDelta * 18.0;

                            final matrix = Matrix4.identity()
                              ..setEntry(3, 2, 0.0014)
                              ..translate(0.0, verticalShift)
                              ..rotateY(rotateY);

                            return Transform(
                              transform: matrix,
                              alignment: Alignment.center,
                              child: AnimatedScale(
                                scale: totalScale,
                                duration: const Duration(milliseconds: 340),
                                curve: Curves.easeOutBack,
                                child: _build3DLuxuryMedallionStage(
                                  product: item,
                                  palette: palette,
                                  isActive: index == safeIdx,
                                ),
                              ),
                            );
                          },
                        ),

                        // C. Tombol Navigasi Panah Kiri/Kanan Halus
                        if (safeIdx > 0)
                          Positioned(
                            left: 12,
                            child: _buildMiniSwipeArrow(
                              icon: Icons.chevron_left_rounded,
                              onTap: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 420),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                            ),
                          ),
                        if (safeIdx < products.length - 1)
                          Positioned(
                            right: 12,
                            child: _buildMiniSwipeArrow(
                              icon: Icons.chevron_right_rounded,
                              onTap: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 420),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  // =========================================================
                  // 4. NAMA PRODUK, SKU & DESKRIPSI DENGAN ANIMASI CROSS-SLIDE
                  // =========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0.0, 0.18),
                          end: Offset.zero,
                        ).animate(anim);
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: slide,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey('info_${currentProduct.id}'),
                        children: [
                          Text(
                            currentProduct.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${currentProduct.sku} • ${currentProduct.isOutOfStock ? "Stok Habis" : "Tersedia (${currentProduct.stock} unit)"}',
                              style: TextStyle(
                                color: currentProduct.isOutOfStock
                                    ? const Color(0xFFFCA5A5)
                                    : palette.haloSecondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            currentProduct.description.isNotEmpty
                                ? currentProduct.description
                                : 'Produk unggulan UMKM berkualitas tinggi dengan bahan pilihan terbaik.',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.74),
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =========================================================
                  // 5. INDIKATOR SLIDE DOTS COMPACT (Anti-Overflow)
                  // =========================================================
                  _buildCompactPaginationIndicator(
                    totalCount: products.length,
                    activeIndex: safeIdx,
                    accentColor: palette.accentButton,
                  ),

                  const SizedBox(height: 12),

                  // =========================================================
                  // 6. PILIHAN UKURAN: SMALL / MEDIUM / LARGE (Persis Video 3!)
                  // =========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: _sizeOptions.map((sizeName) {
                        final isSelected = _selectedSize == sizeName;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSize = sizeName;
                                });
                                _sizePulseWaveController.forward(from: 0.0);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            palette.accentButton,
                                            palette.haloPrimary,
                                          ],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.45)
                                        : Colors.white.withValues(alpha: 0.14),
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: palette.accentButton
                                                .withValues(alpha: 0.45),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  sizeName,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.72),
                                    fontSize: 12.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =========================================================
                  // 7. DUA KOTAK METRIK: PRICE & SCORE/STOK (Persis Video 3!)
                  // =========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildFrostedMetricBox(
                            icon: Icons.local_cafe_rounded,
                            label: 'Price ($_selectedSize)',
                            value: CurrencyFormatter.formatRupiah(dynamicPrice),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFrostedMetricBox(
                            icon: Icons.star_rounded,
                            label: 'Score • Stok',
                            value: '4.9 ★ • ${currentProduct.stock} unit',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =========================================================
                  // 8. TOMBOL UTAMA: CONFIRM SELECTION • TAMBAH KASIR
                  // =========================================================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: currentProduct.isOutOfStock
                                ? [Colors.grey.shade700, Colors.grey.shade800]
                                : [
                                    Colors.white,
                                    const Color(0xFFFFEDD5),
                                    palette.haloPrimary,
                                  ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  palette.haloPrimary.withValues(alpha: 0.42),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: const Color(0xFF1E120A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: currentProduct.isOutOfStock
                              ? null
                              : () {
                                  final error = cartProvider.addToCart(
                                    currentProduct,
                                    variant: _selectedSize,
                                    unitPriceOverride: dynamicPrice,
                                  );
                                  if (error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(error),
                                        backgroundColor: AppColors.warningAmber,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '✓ ${currentProduct.name} ($_selectedSize • ${CurrencyFormatter.formatRupiah(dynamicPrice)}) ditambahkan ke Kasir POS!',
                                        ),
                                        backgroundColor:
                                            AppColors.loginPrimaryGreen,
                                        duration:
                                            const Duration(milliseconds: 1600),
                                      ),
                                    );
                                  }
                                },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_rounded,
                                size: 19,
                                color: Color(0xFF1E120A),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currentProduct.isOutOfStock
                                    ? 'Stok Habis'
                                    : 'Confirm Selection • Tambah Kasir',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E120A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  /// Panggung 3D Luxury Studio Medallion:
  /// Menampilkan foto asli produk 100% UTUH & TAJAM di dalam medali 3D berlapis cincin emas,
  /// kilau kaca bergerak (specular glass sweep), dan bayangan lantai 3D di bawahnya!
  Widget _build3DLuxuryMedallionStage({
    required ProductModel product,
    required _StudioPalette palette,
    required bool isActive,
  }) {
    return AnimatedBuilder(
      animation: _orbitAndFloatController,
      builder: (context, _) {
        final phase = _orbitAndFloatController.value;
        final wave = math.sin(phase * math.pi * 2);
        final floatY = isActive ? wave * -6.5 : 0.0;
        final shadowScale = isActive ? (1.0 - (wave * -0.07)) : 0.85;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Bayangan Lantai 3D Oval di Bawah Medali yang Melayang
            Positioned(
              bottom: 12,
              child: Transform.scale(
                scaleX: shadowScale * 1.15,
                scaleY: shadowScale * 0.38,
                child: Container(
                  width: 164,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.72),
                        blurRadius: 26,
                        spreadRadius: 6,
                      ),
                      BoxShadow(
                        color: palette.haloPrimary.withValues(alpha: 0.30),
                        blurRadius: 34,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Medali Studio 3D Melayang dengan Cincin Bezel Emas/Kaca & Foto Produk Utuh
            Transform.translate(
              offset: Offset(0, floatY),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // A. Bezel Cincin Medali 3D (Gradasi Rim-Light Emas ke Perunggu Gelap)
                  Container(
                    width: 214,
                    height: 214,
                    padding: const EdgeInsets.all(6.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          palette.rimLight.withValues(alpha: 0.88),
                          palette.haloPrimary.withValues(alpha: 0.55),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        stops: const [0.0, 0.50, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: palette.haloPrimary.withValues(alpha: 0.42),
                          blurRadius: 32,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    // B. Foto Produk Asli 100% Utuh & Jernih + Kilau Kaca Specular 3D
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomProductImage(
                            imageUrl: product.primaryImage,
                            width: 201,
                            height: 201,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(110),
                            fallbackLabel: product.name,
                          ),
                          // Vignette tepi dalam super halus untuk kedalaman bola kaca 3D
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.34),
                                ],
                                stops: const [0.0, 0.78, 1.0],
                              ),
                            ),
                          ),
                          // Kilau kaca diagonal bergerak lembut (3D Glass Specular Sweep)
                          if (isActive)
                            IgnorePointer(
                              child: CustomPaint(
                                painter: _MedallionGlassSheenPainter(
                                  phase: phase,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // C. Lencana Kecil Ciri Khas "★ 4.9 • Signature" di Bawah Medali 3D
                  if (isActive)
                    Positioned(
                      bottom: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              palette.accentButton,
                              palette.haloPrimary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: palette.rimLight.withValues(alpha: 0.75),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 11.5,
                              color: palette.rimLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'CloudPOS Signature • $_selectedSize',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactPaginationIndicator({
    required int totalCount,
    required int activeIndex,
    required Color accentColor,
  }) {
    final maxDots = math.min(totalCount, 10);
    final startIdx = totalCount <= maxDots
        ? 0
        : (activeIndex - (maxDots ~/ 2)).clamp(0, totalCount - maxDots);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(maxDots, (i) {
          final itemIdx = startIdx + i;
          final isSelected = itemIdx == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            width: isSelected ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${activeIndex + 1} / $totalCount',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCircleIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    double iconSize = 20,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }

  Widget _buildMiniSwipeArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.38),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    value,
                    key: ValueKey(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
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

class _StudioPalette {
  final Color bgTop;
  final Color bgCenter;
  final Color bgBottom;
  final Color haloPrimary;
  final Color haloSecondary;
  final Color accentButton;
  final Color rimLight;

  const _StudioPalette({
    required this.bgTop,
    required this.bgCenter,
    required this.bgBottom,
    required this.haloPrimary,
    required this.haloSecondary,
    required this.accentButton,
    required this.rimLight,
  });
}

/// Painter Panggung Orbit Kembar 3D, Gelombang Kejut Ukuran & Bintang Emas di Luar Medali
class _LuxuryOrbitalStagePainter extends CustomPainter {
  final double orbitPhase;
  final double pulseValue;
  final double shockwaveValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Color rimLightColor;

  _LuxuryOrbitalStagePainter({
    required this.orbitPhase,
    required this.pulseValue,
    required this.shockwaveValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.rimLightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = 112.0 + (pulseValue * 5.0);

    // 1. Halo Radial Lembut di Belakang Medali
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.45),
          secondaryColor.withValues(alpha: 0.16),
          primaryColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.38));
    canvas.drawCircle(center, baseRadius * 1.38, glowPaint);

    // 2. Efek Gelombang Kejut (Shockwave Ring) Saat Pilih Ukuran / Ganti Produk
    if (shockwaveValue > 0.0 && shockwaveValue < 1.0) {
      final swRadius = 104.0 + (shockwaveValue * 52.0);
      final swAlpha = (1.0 - shockwaveValue) * 0.55;
      canvas.drawCircle(
        center,
        swRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1.0 - shockwaveValue)
          ..color = rimLightColor.withValues(alpha: swAlpha),
      );
    }

    // 3. Cincin Orbit Dalam Berputar Searah Jarum Jam + Titik Komet Bercahaya
    final orbitRadius1 = 118.0;
    final arcRect1 = Rect.fromCircle(center: center, radius: orbitRadius1);
    final angle1 = orbitPhase * math.pi * 2;
    final arcPaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = rimLightColor.withValues(alpha: 0.42);

    canvas.drawArc(arcRect1, angle1, math.pi * 0.55, false, arcPaint1);
    canvas.drawArc(
      arcRect1,
      angle1 + math.pi,
      math.pi * 0.55,
      false,
      arcPaint1,
    );

    // Titik komet emas di ujung busur orbit
    for (final a in [angle1 + math.pi * 0.55, angle1 + math.pi * 1.55]) {
      final nodePos = Offset(
        center.dx + math.cos(a) * orbitRadius1,
        center.dy + math.sin(a) * orbitRadius1,
      );
      canvas.drawCircle(
        nodePos,
        4.5,
        Paint()
          ..color = secondaryColor.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
      );
      canvas.drawCircle(
        nodePos,
        2.2,
        Paint()..color = Colors.white,
      );
    }

    // 4. Cincin Orbit Luar Berputar Berlawanan Arah Jarum Jam
    final orbitRadius2 = 132.0;
    final arcRect2 = Rect.fromCircle(center: center, radius: orbitRadius2);
    final angle2 = -orbitPhase * math.pi * 2;
    final arcPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = secondaryColor.withValues(alpha: 0.26);

    canvas.drawArc(arcRect2, angle2, math.pi * 0.35, false, arcPaint2);
    canvas.drawArc(
      arcRect2,
      angle2 + math.pi,
      math.pi * 0.35,
      false,
      arcPaint2,
    );

    // 5. Partikel Bintang Mahkota & Bokeh Emas di LUAR Medali (Radius 122..148 px)
    //    Sehingga foto makanan/produk tetap 100% bersih dan jernih!
    for (int i = 0; i < 8; i++) {
      final seed = i * 0.92;
      final twinkle =
          (0.4 + 0.6 * math.sin((orbitPhase * math.pi * 6) + seed))
              .clamp(0.15, 1.0);
      final pAngle = (i / 8.0) * math.pi * 2 + (orbitPhase * math.pi * 0.5);
      final pRadius = 124.0 + (i % 3) * 9.0 + math.sin(seed) * 4.0;

      final px = center.dx + math.cos(pAngle) * pRadius;
      final py = center.dy + math.sin(pAngle) * pRadius;
      final starSize = (2.2 + (i % 2) * 1.4) * twinkle;
      final starColor =
          (i.isEven ? rimLightColor : secondaryColor).withValues(
        alpha: (0.75 * twinkle).clamp(0.0, 1.0),
      );

      if (i % 2 == 0) {
        _drawSparkleStar(canvas, Offset(px, py), starSize * 1.8, starColor);
      } else {
        canvas.drawCircle(
          Offset(px, py),
          starSize,
          Paint()..color = starColor,
        );
      }
    }
  }

  void _drawSparkleStar(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _LuxuryOrbitalStagePainter oldDelegate) =>
      oldDelegate.orbitPhase != orbitPhase ||
      oldDelegate.pulseValue != pulseValue ||
      oldDelegate.shockwaveValue != shockwaveValue ||
      oldDelegate.primaryColor != primaryColor;
}

/// Painter Kilau Kaca Specular 3D yang Melintas Lembut di Atas Permukaan Medali Produk
class _MedallionGlassSheenPainter extends CustomPainter {
  final double phase;

  _MedallionGlassSheenPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Highlight lengkung kaca 3D tetap di sudut kiri-atas medali
    final topGlossRect = Rect.fromLTWH(w * 0.08, h * 0.04, w * 0.84, h * 0.42);
    canvas.drawOval(
      topGlossRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(topGlossRect),
    );

    // Pita kilau diagonal lembut yang melintas periodik
    final sweepProgress = ((phase * 1.5) % 1.0);
    if (sweepProgress < 0.55) {
      final t = sweepProgress / 0.55;
      final sx = -w * 0.6 + (t * w * 2.2);
      final path = Path()
        ..moveTo(sx, 0)
        ..lineTo(sx + w * 0.26, 0)
        ..lineTo(sx - w * 0.14, h)
        ..lineTo(sx - w * 0.40, h)
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.18),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MedallionGlassSheenPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
