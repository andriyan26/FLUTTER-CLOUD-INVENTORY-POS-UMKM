import 'dart:math' as math;
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

/// Halaman Detail Produk Interaktif 3D Studio Cutout & Swipe Carousel
/// Mengikuti secara presisi VIDEO 3 (KONSEP LIHAT DETAIL BARANG.mp4 detik 00:00 - 00:21):
/// - Produk tampil dengan Background Terhapus (3D Studio Cutout PNG `assets/produk_cutout/*.png`)
///   melayang di atas pedestal lingkaran cahaya (radial halo spotlight) + bayangan lantai 3D.
/// - Dilengkapi ANIMASI 60FPS DI ATAS PRODUK: kepulan uap/aroma hangat S-curve yang naik perlahan,
///   kilau partikel bintang keemasan (golden sparkles), dan cincin orbit cahaya berputar.
/// - Carousel 3D Parallax (`viewportFraction: 0.78`) di mana produk sebelah kiri/kanan mengintip
///   dan membesar secara mulus saat di-swipe.
/// - Interaksi tombol ukuran `Small`, `Medium`, `Large` yang mengubah skala 3D produk
///   (`0.84x`, `1.00x`, `1.15x`) serta harga secara real-time.
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
  late final AnimationController _ambientController;
  late final AnimationController _pulseController;

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
      viewportFraction: 0.78,
    )..addListener(_onPageScroll);

    // Controller 60fps untuk uap aroma di atas produk, partikel kilau & levitasi 3D
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();

    // Controller denyut halo spotlight & bayangan lantai 3D
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  void _onPageScroll() {
    if (!mounted || !_pageController.hasClients) return;
    setState(() {
      _currentPageValue =
          _pageController.page ?? _currentIndex.toDouble();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _ambientController.dispose();
    _pulseController.dispose();
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
        return 0.84;
      case 'Large':
        return 1.15;
      default:
        return 1.00;
    }
  }

  /// Resolusi otomatis dari `assets/produk/xxx.jpg` ke `assets/produk_cutout/xxx.png`
  /// sehingga gambar produk tampil tanpa background kotak (3D Studio Cutout)
  String _resolveCutoutAssetPath(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.startsWith('assets/produk/') && trimmed.endsWith('.jpg')) {
      final fileName = trimmed.substring('assets/produk/'.length);
      final baseName = fileName.substring(0, fileName.length - 4);
      return 'assets/produk_cutout/$baseName.png';
    }
    return trimmed;
  }

  /// Palet warna studio spotlight dinamis berdasarkan kategori produk
  _StudioPalette _getPaletteForCategory(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('minum') || lower.contains('kopi')) {
      return const _StudioPalette(
        bgTop: Color(0xFF23120B),
        bgCenter: Color(0xFF4A2511),
        bgBottom: Color(0xFF140A06),
        haloPrimary: Color(0xFFD97736),
        haloSecondary: Color(0xFFF59E0B),
        accentButton: Color(0xFFE07A38),
        steamColor: Color(0xFFFFEDD5),
        hasWarmSteam: true,
      );
    } else if (lower.contains('makan') || lower.contains('kuliner')) {
      return const _StudioPalette(
        bgTop: Color(0xFF28100E),
        bgCenter: Color(0xFF571E16),
        bgBottom: Color(0xFF160807),
        haloPrimary: Color(0xFFEF5B2A),
        haloSecondary: Color(0xFFFBBF24),
        accentButton: Color(0xFFEA580C),
        steamColor: Color(0xFFFEF3C7),
        hasWarmSteam: true,
      );
    } else if (lower.contains('roti') || lower.contains('pastry')) {
      return const _StudioPalette(
        bgTop: Color(0xFF102229),
        bgCenter: Color(0xFF1E3F4C),
        bgBottom: Color(0xFF091418),
        haloPrimary: Color(0xFF38BDF8),
        haloSecondary: Color(0xFFF59E0B),
        accentButton: Color(0xFF0284C7),
        steamColor: Color(0xFFE0F2FE),
        hasWarmSteam: true,
      );
    } else if (lower.contains('cemilan') || lower.contains('snack')) {
      return const _StudioPalette(
        bgTop: Color(0xFF26170A),
        bgCenter: Color(0xFF523214),
        bgBottom: Color(0xFF140C05),
        haloPrimary: Color(0xFFF59E0B),
        haloSecondary: Color(0xFFFB923C),
        accentButton: Color(0xFFD97706),
        steamColor: Color(0xFFFEF08A),
        hasWarmSteam: true,
      );
    } else if (lower.contains('sembako')) {
      return const _StudioPalette(
        bgTop: Color(0xFF0D2118),
        bgCenter: Color(0xFF18422F),
        bgBottom: Color(0xFF07130E),
        haloPrimary: Color(0xFF10B981),
        haloSecondary: Color(0xFFFBBF24),
        accentButton: Color(0xFF059669),
        steamColor: Color(0xFFD1FAE5),
        hasWarmSteam: false,
      );
    }
    return const _StudioPalette(
      bgTop: Color(0xFF111827),
      bgCenter: Color(0xFF1E293B),
      bgBottom: Color(0xFF090D16),
      haloPrimary: Color(0xFF60A5FA),
      haloSecondary: Color(0xFF38BDF8),
      accentButton: Color(0xFF2563EB),
      steamColor: Color(0xFFDBEAFE),
      hasWarmSteam: false,
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

    // Daftar kategori unik untuk switcher cepat di atas
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
            center: const Alignment(0.0, -0.22),
            radius: 1.05,
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
                  // 1. TOP BAR: Tombol Back, Judul Kategori & Aksi Admin/Fav
                  // =========================================================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        _buildGlassCircleIconButton(
                          icon: Icons.chevron_left_rounded,
                          tooltip: 'Kembali',
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What would you like to order today?',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.68),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
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
                  // 3. PANGGUNG 3D STUDIO CUTOUT + ANIMASI UAP & PARTIKEL DI ATASNYA
                  // =========================================================
                  Expanded(
                    flex: 6,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // A. Cincin Halo Cahaya Berputar & Berdenyut di Belakang Produk
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _ambientController,
                            _pulseController,
                          ]),
                          builder: (context, _) {
                            return CustomPaint(
                              size: const Size(290, 290),
                              painter: _StudioPedestalHaloPainter(
                                orbitPhase: _ambientController.value,
                                pulseValue: _pulseController.value,
                                primaryColor: palette.haloPrimary,
                                secondaryColor: palette.haloSecondary,
                              ),
                            );
                          },
                        ),

                        // B. Carousel Swipe 3D Parallax Produk (Tanpa Background Kotak!)
                        PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: products.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final item = products[index];
                            final delta = (index - _currentPageValue);
                            final absDelta = delta.abs().clamp(0.0, 1.5);

                            // Skala parallax 3D saat di-swipe + skala ukuran Small/Medium/Large
                            final parallaxScale =
                                (1.0 - (absDelta * 0.28)).clamp(0.68, 1.0);
                            final activeSizeScale =
                                index == safeIdx ? _getSizeScaleFactor() : 0.88;
                            final totalScale = parallaxScale * activeSizeScale;
                            final rotationZ = delta * -0.14;
                            final verticalShift = absDelta * 22.0;

                            return AnimatedScale(
                              scale: totalScale,
                              duration: const Duration(milliseconds: 340),
                              curve: Curves.easeOutBack,
                              child: Transform.translate(
                                offset: Offset(0, verticalShift),
                                child: Transform.rotate(
                                  angle: rotationZ,
                                  child: _build3DFloatingCutoutStage(
                                    product: item,
                                    palette: palette,
                                    isActive: index == safeIdx,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // C. ANIMASI DI ATAS PRODUK: Kepulan Uap Aroma & Kilau Bintang Emas 60fps
                        IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _ambientController,
                            builder: (context, _) {
                              return CustomPaint(
                                size: const Size(300, 290),
                                painter: _UpperAromaAndSparklePainter(
                                  phase: _ambientController.value,
                                  steamColor: palette.steamColor,
                                  sparkleColor: palette.haloSecondary,
                                  showWarmSteam: palette.hasWarmSteam,
                                ),
                              );
                            },
                          ),
                        ),

                        // D. Tombol Navigasi Panah Kiri/Kanan Halus
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
                            value: '4.9 • ${currentProduct.stock} unit',
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
                                  final error = cartProvider.addProduct(
                                    currentProduct,
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

  /// Panggung 3D Cutout Produk dengan Levitasi 60fps & Bayangan Lantai 3D
  Widget _build3DFloatingCutoutStage({
    required ProductModel product,
    required _StudioPalette palette,
    required bool isActive,
  }) {
    final cutoutPath = _resolveCutoutAssetPath(product.primaryImage);
    final isTransparentCutoutAsset =
        cutoutPath.startsWith('assets/produk_cutout/');

    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final wave = math.sin(_ambientController.value * math.pi * 2);
        final floatY = isActive ? wave * -7.5 : 0.0;
        final tiltAngle = isActive
            ? math.cos(_ambientController.value * math.pi * 2) * 0.024
            : 0.0;
        final shadowScale = isActive ? (1.0 - (wave * -0.08)) : 0.85;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Bayangan Lantai 3D Oval di Bawah Produk yang Melayang
            Positioned(
              bottom: 14,
              child: Transform.scale(
                scaleX: shadowScale * 1.15,
                scaleY: shadowScale * 0.42,
                child: Container(
                  width: 155,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.68),
                        blurRadius: 26,
                        spreadRadius: 6,
                      ),
                      BoxShadow(
                        color: palette.haloPrimary.withValues(alpha: 0.25),
                        blurRadius: 34,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Gambar Produk 3D Cutout Melayang Halus Tanpa Border Kaku
            Transform.translate(
              offset: Offset(0, floatY),
              child: Transform.rotate(
                angle: tiltAngle,
                child: child,
              ),
            ),
          ],
        );
      },
      child: Container(
        width: 224,
        height: 224,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: palette.haloPrimary.withValues(alpha: 0.28),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child: isTransparentCutoutAsset
            ? Image.asset(
                cutoutPath,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => _buildFeatheredFallbackImage(
                  product.primaryImage,
                  product.name,
                ),
              )
            : _buildFeatheredFallbackImage(
                product.primaryImage,
                product.name,
              ),
      ),
    );
  }

  /// Untuk foto baru yang di-upload pengguna dari perangkat (Data URI / URL),
  /// gunakan ShaderMask Radial Feathering agar pinggirannya menyatu lembut tanpa garis kaku
  Widget _buildFeatheredFallbackImage(String imageUrl, String label) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const RadialGradient(
          center: Alignment.center,
          radius: 0.49,
          colors: [
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [0.0, 0.78, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: CustomProductImage(
        imageUrl: imageUrl,
        width: 212,
        height: 212,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(110),
        fallbackLabel: label,
      ),
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
  final Color steamColor;
  final bool hasWarmSteam;

  const _StudioPalette({
    required this.bgTop,
    required this.bgCenter,
    required this.bgBottom,
    required this.haloPrimary,
    required this.haloSecondary,
    required this.accentButton,
    required this.steamColor,
    required this.hasWarmSteam,
  });
}

/// Painter Pedestal Lingkaran Cahaya (Spotlight Halo) & Cincin Orbit Berputar di Belakang Produk
class _StudioPedestalHaloPainter extends CustomPainter {
  final double orbitPhase;
  final double pulseValue;
  final Color primaryColor;
  final Color secondaryColor;

  _StudioPedestalHaloPainter({
    required this.orbitPhase,
    required this.pulseValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.37 + (pulseValue * 6.0);

    // 1. Halo Radial Lembut Berlapis (Tanpa Garis Kaku)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.42),
          secondaryColor.withValues(alpha: 0.18),
          primaryColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.62, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.32));
    canvas.drawCircle(center, baseRadius * 1.32, glowPaint);

    // 2. Piringan Spotlight Studio Dalam (Seperti Lingkaran Pedestal di Video 3)
    final discPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.25),
        colors: [
          Colors.white.withValues(alpha: 0.16),
          primaryColor.withValues(alpha: 0.24),
          Colors.black.withValues(alpha: 0.18),
        ],
        stops: const [0.0, 0.68, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 0.92));
    canvas.drawCircle(center, baseRadius * 0.92, discPaint);

    // 3. Dua Busur Cahaya Orbit Berputar Halus Mengelilingi Produk
    final arcRect = Rect.fromCircle(center: center, radius: baseRadius * 1.02);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = secondaryColor.withValues(alpha: 0.38);

    final startAngle1 = orbitPhase * math.pi * 2;
    canvas.drawArc(arcRect, startAngle1, math.pi * 0.42, false, arcPaint);
    canvas.drawArc(
      arcRect,
      startAngle1 + math.pi,
      math.pi * 0.42,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StudioPedestalHaloPainter oldDelegate) =>
      oldDelegate.orbitPhase != orbitPhase ||
      oldDelegate.pulseValue != pulseValue ||
      oldDelegate.primaryColor != primaryColor;
}

/// Painter Animasi di Atas Produk:
/// - Kepulan Uap / Aroma Hangat S-Curve yang Mengalir Naik Perlahan di Atas Produk
/// - Partikel Bintang & Bokeh Keemasan yang Berkilau di Atas Mahkota Produk
class _UpperAromaAndSparklePainter extends CustomPainter {
  final double phase;
  final Color steamColor;
  final Color sparkleColor;
  final bool showWarmSteam;

  _UpperAromaAndSparklePainter({
    required this.phase,
    required this.steamColor,
    required this.sparkleColor,
    required this.showWarmSteam,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // 1. TIGA PITA UAP AROMA HANGAT MENGALIR NAIK DI ATAS PRODUK
    if (showWarmSteam) {
      final steamOffsets = [-32.0, 0.0, 32.0];
      for (int i = 0; i < steamOffsets.length; i++) {
        final localProgress = (phase + (i * 0.33)) % 1.0;
        final alpha = math.sin(localProgress * math.pi).clamp(0.0, 1.0) * 0.34;
        if (alpha <= 0.01) continue;

        final baseX = cx + steamOffsets[i];
        final startY = size.height * 0.34 - (localProgress * 28.0);
        final endY = startY - 46.0 - (localProgress * 18.0);
        final sway = math.sin((phase * math.pi * 2) + i * 1.4) * 11.0;

        final path = Path()
          ..moveTo(baseX, startY)
          ..cubicTo(
            baseX - sway,
            startY - 16,
            baseX + sway,
            startY - 32,
            baseX + (sway * 0.4),
            endY,
          );

        final steamPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2 - (localProgress * 1.2)
          ..strokeCap = StrokeCap.round
          ..color = steamColor.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);

        canvas.drawPath(path, steamPaint);
      }
    }

    // 2. PARTIKEL KILAU BINTANG & BOKEH EMAS DI ATAS & SEKITAR PRODUK
    for (int i = 0; i < 9; i++) {
      final seed = i * 1.37;
      final p = (phase + (i * 0.11)) % 1.0;
      final twinkle = (0.5 + 0.5 * math.sin((phase * math.pi * 4) + seed))
          .clamp(0.15, 1.0);
      final fade = math.sin(p * math.pi).clamp(0.0, 1.0);

      final angle = -math.pi * 0.85 + (i / 8.0) * (math.pi * 0.70);
      final radius = 84.0 + (p * 36.0) + math.sin(seed) * 10.0;
      final px = cx + math.cos(angle) * radius;
      final py = (size.height * 0.46) + math.sin(angle) * radius - (p * 18.0);

      final dotRadius = (1.6 + (i % 3) * 0.9) * twinkle;
      final color = (i.isEven ? sparkleColor : steamColor)
          .withValues(alpha: (0.72 * fade * twinkle).clamp(0.0, 1.0));

      // Glow lembut di sekitar bintang
      canvas.drawCircle(
        Offset(px, py),
        dotRadius * 2.2,
        Paint()
          ..color = color.withValues(alpha: color.a * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
      );

      // Bintang 4 sudut di atas produk untuk partikel utama
      if (i % 2 == 0) {
        _drawSparkleStar(canvas, Offset(px, py), dotRadius * 2.1, color);
      } else {
        canvas.drawCircle(Offset(px, py), dotRadius, Paint()..color = color);
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
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx,
        center.dy - radius,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _UpperAromaAndSparklePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.steamColor != steamColor ||
      oldDelegate.showWarmSteam != showWarmSteam;
}
