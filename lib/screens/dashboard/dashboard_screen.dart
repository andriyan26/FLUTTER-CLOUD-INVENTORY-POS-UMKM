import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/cloud_pos_brand_logo.dart';
import '../../core/widgets/custom_cached_image.dart';
import '../../core/widgets/smooth_staggered_reveal.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/category_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/stat_card.dart';
import '../auth/splash_screen.dart';
import '../categories/category_management_screen.dart';
import '../pos/live_delivery_tracker_dialog.dart';
import '../pos/quick_add_sheet.dart';
import '../products/product_detail_swipe_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onSwitchTab;

  const DashboardScreen({
    super.key,
    this.onSwitchTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  String _selectedChartPeriod = 'Mingguan';
  int _categoryAnimVersion = 0;
  bool _showWaveBanner = false;
  late final AnimationController _bannerScooterController;

  @override
  void initState() {
    super.initState();
    _bannerScooterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _bannerScooterController.dispose();
    super.dispose();
  }

  void _openProductSwipeDetail(ProductModel product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: ProductDetailSwipeScreen(initialProduct: product),
        ),
      ),
    );
  }

  void _openQuickAddSheet(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddProductSheet(product: product),
    );
  }

  void _triggerCategorySwitch(ProductProvider provider, String categoryId) {
    provider.setCategoryFilter(categoryId);
    setState(() {
      _categoryAnimVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final txProvider = context.watch<TransactionProvider>();

    final user = auth.currentUser;
    final products = productProvider.filteredProducts;
    final categories = categoryProvider.categories;
    final lowStockList = productProvider.lowStockProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.posOrange,
          onRefresh: () async {
            setState(() => _showWaveBanner = true);
            await Future.wait([
              productProvider.loadProducts(),
              categoryProvider.loadCategories(),
              txProvider.loadTransactions(),
            ]);
            await Future.delayed(const Duration(milliseconds: 900));
            if (mounted) {
              setState(() => _showWaveBanner = false);
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutBack,
                        child: _showWaveBanner
                            ? Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.posOrangeLight,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.waving_hand_rounded,
                                      color: AppColors.posOrange,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Data stok & katalog disinkronkan!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.posOrangeDark,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // 1. HEADER ATAS MUNCUL PERLAHAN & SMOOTH (Persis Video 2: "Bonjour, Andriyan")
                      SmoothStaggeredReveal(
                        index: 0,
                        beginOffset: const Offset(0, -0.15),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => widget.onSwitchTab?.call(5),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2.2),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.posOrange,
                                          Color(0xFFF59E0B),
                                          AppColors.loginPrimaryGreen,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x33F05A28),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CustomAvatarImage(
                                      avatarUrl: user?.avatarUrl ?? '',
                                      fullName: user?.fullName ?? 'Andriyan',
                                      size: 42,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF22C55E),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => widget.onSwitchTab?.call(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjour, ${user?.fullName.split(' ').first ?? 'Andriyan'} 👋',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textDarkSlate,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user?.storeName ??
                                                'CloudPOS • Cabang Utama UMKM',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11.2,
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 15,
                                          color: AppColors.textMuted,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.posOrange.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14F05A28),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CloudPosEmblemIcon(
                                    size: 24,
                                    animate: true,
                                    showCrownBadge: false,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'CloudPOS',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.posOrange,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 7),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0A0F172A),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    size: 20,
                                    color: AppColors.textDarkSlate,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 9,
                                  child: Container(
                                    width: 7.5,
                                    height: 7.5,
                                    decoration: BoxDecoration(
                                      color: AppColors.posOrange,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 2. HERO HEADLINE + LIVE MENU BADGE + SEARCH BAR MUNCUL PERLAHAN
                      SmoothStaggeredReveal(
                        index: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontSize: 23.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.7,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Ada pesanan ? ',
                                          style: TextStyle(
                                            color: AppColors.textDarkSlate,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Layani Cepat.',
                                          style: TextStyle(
                                            color: AppColors.posOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.5,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFF4ED),
                                        Color(0xFFFFE4D4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.posOrange
                                          .withValues(alpha: 0.28),
                                    ),
                                  ),
                                  child: Text(
                                    '✨ ${productProvider.totalProductsCount} Menu',
                                    style: const TextStyle(
                                      fontSize: 10.2,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.posOrangeDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 11),
                            Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.only(left: 16, right: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: const Color(0xFFE8ECF2),
                                  width: 1.3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0D0F172A),
                                    blurRadius: 16,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.manage_search_rounded,
                                    color: AppColors.posOrange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (val) {
                                        productProvider.setSearchQuery(val);
                                        setState(() => _categoryAnimVersion++);
                                      },
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Rechercher / Cari produk, SKU...',
                                        hintStyle: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12.8,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF8A3D),
                                          AppColors.posOrange,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x38F05A28),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.search_rounded,
                                      color: Colors.white,
                                      size: 19,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 3. PROMO BANNER 3D MEWAH HIJAU ZAMRUD DENGAN ANIMASI MOTOR & STRIP RINGKASAN KASIR
                      SmoothStaggeredReveal(
                        index: 2,
                        child: Column(
                          children: [
                            Container(
                              height: 118,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1B3F0D),
                                    Color(0xFF2D6016),
                                    Color(0xFF4E8D2A),
                                  ],
                                  stops: [0.0, 0.55, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x34285214),
                                    blurRadius: 18,
                                    offset: Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Dekorasi Lingkaran Cahaya Emas di Sudut Kanan Atas Banner
                                  Positioned(
                                    right: -24,
                                    top: -28,
                                    child: Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(0xFFBEF264)
                                                .withValues(alpha: 0.25),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        AnimatedBuilder(
                                          animation: _bannerScooterController,
                                          builder: (context, _) {
                                            final bounceY = math.sin(
                                                  _bannerScooterController
                                                          .value *
                                                      math.pi *
                                                      2,
                                                ) *
                                                -3.0;
                                            return Transform.translate(
                                              offset: Offset(0, bounceY),
                                              child:
                                                  CloudPosScooterIllustration(
                                                size: 86,
                                                wheelPhase:
                                                    _bannerScooterController
                                                        .value,
                                                showSpeedLines: true,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 7,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.24),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Text(
                                                  '● LIVE CLOUD POS & DELIVERY',
                                                  style: TextStyle(
                                                    color: Color(0xFFBEF264),
                                                    fontSize: 8.8,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.4,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              const Text(
                                                'FAST & CLOUD POS DELIVERY',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13.2,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                              const Text(
                                                'Kasir, stok & kurir skuter aktif real-time',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Color(0xFFE2F2D5),
                                                  fontSize: 10.6,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 7),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () => widget
                                                        .onSwitchTab
                                                        ?.call(2),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4.5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                          colors: [
                                                            Color(0xFFFF8A3D),
                                                            AppColors.posOrange,
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Color(
                                                              0x44F05A28,
                                                            ),
                                                            blurRadius: 6,
                                                            offset: Offset(
                                                              0,
                                                              2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: const Text(
                                                        '⚡ BUKA KASIR',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 9.5,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            const LiveDeliveryTrackerDialog(),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 9,
                                                        vertical: 4.5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(
                                                          alpha: 0.18,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14),
                                                        border: Border.all(
                                                          color: Colors.white
                                                              .withValues(
                                                            alpha: 0.45,
                                                          ),
                                                        ),
                                                      ),
                                                      child: const Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .location_on_rounded,
                                                            color: Color(
                                                              0xFFBEF264,
                                                            ),
                                                            size: 11,
                                                          ),
                                                          SizedBox(width: 3),
                                                          Text(
                                                            'KURIR LIVE',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 9.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                            ),
                                                          ),
                                                        ],
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
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Strip Ringkasan Kasir Cepat (3 Luxury Glass Pills)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickPulsePill(
                                    icon: Icons.payments_rounded,
                                    iconColor: AppColors.loginPrimaryGreen,
                                    label: 'Omzet Hari Ini',
                                    value:
                                        CurrencyFormatter.formatCompactRupiah(
                                      txProvider.todaySalesTotal,
                                    ),
                                    onTap: () => widget.onSwitchTab?.call(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildQuickPulsePill(
                                    icon: Icons.grid_view_rounded,
                                    iconColor: AppColors.posOrange,
                                    label: 'Katalog Aktif',
                                    value:
                                        '${productProvider.totalProductsCount} Item • 6 Kat',
                                    onTap: () => widget.onSwitchTab?.call(1),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildQuickPulsePill(
                                    icon: Icons.verified_rounded,
                                    iconColor: const Color(0xFFF59E0B),
                                    label: 'Rating UMKM',
                                    value: '4.9 ★ Terbaik',
                                    onTap: () => widget.onSwitchTab?.call(3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 4. HORIZONTAL CATEGORY CAROUSEL BULAT BERGAMBAR + IKON MOSAIC KHUSUS "SEMUA" (BUKAN BURGER!)
                      SmoothStaggeredReveal(
                        index: 3,
                        child: SizedBox(
                          height: 98,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: categories.length + 1,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final isAll = index == 0;
                              final catId =
                                  isAll ? 'all' : categories[index - 1].id;
                              final fullCatName = isAll
                                  ? 'Semua'
                                  : categories[index - 1].name;
                              final shortName = fullCatName.split(' ').first;
                              final isSelected =
                                  productProvider.selectedCategoryId == catId;
                              final thumbUrl = isAll
                                  ? ''
                                  : CategoryService.getCategoryThumbnail(
                                      fullCatName,
                                    );
                              final itemCount = isAll
                                  ? productProvider.totalProductsCount
                                  : productProvider.allProducts
                                      .where(
                                        (p) =>
                                            p.categoryId == catId ||
                                            p.categoryName.toLowerCase() ==
                                                fullCatName.toLowerCase(),
                                      )
                                      .length;

                              return GestureDetector(
                                onTap: () => _triggerCategorySwitch(
                                  productProvider,
                                  catId,
                                ),
                                child: Column(
                                  children: [
                                    AnimatedScale(
                                      scale: isSelected ? 1.08 : 1.0,
                                      duration:
                                          const Duration(milliseconds: 240),
                                      curve: Curves.easeOutBack,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 240,
                                            ),
                                            width: 64,
                                            height: 64,
                                            padding: const EdgeInsets.all(3.5),
                                            decoration: BoxDecoration(
                                              gradient: isSelected
                                                  ? const LinearGradient(
                                                      colors: [
                                                        Color(0xFFFFEDE4),
                                                        Color(0xFFFFD8C4),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    )
                                                  : const LinearGradient(
                                                      colors: [
                                                        Colors.white,
                                                        Color(0xFFF3EFEA),
                                                      ],
                                                    ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.posOrange
                                                    : const Color(0xFFE5E0D8),
                                                width: isSelected ? 2.4 : 1.2,
                                              ),
                                              boxShadow: isSelected
                                                  ? const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x38F05A28),
                                                        blurRadius: 12,
                                                        offset: Offset(0, 4),
                                                      ),
                                                    ]
                                                  : const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x0A0F172A),
                                                        blurRadius: 6,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                            ),
                                            // KHUSUS "SEMUA": Tampilkan Kolase 4 Kategori + Ikon Grid 3D (Bukan Gambar Burger!)
                                            child: isAll
                                                ? _buildAllCategoriesMosaicCircle(
                                                    isSelected,
                                                  )
                                                : CustomProductImage(
                                                    imageUrl: thumbUrl,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      40,
                                                    ),
                                                    fallbackLabel: shortName,
                                                  ),
                                          ),
                                          // Badge Jumlah Produk di Sudut Kanan Bawah Lingkaran Kategori
                                          Positioned(
                                            right: -2,
                                            bottom: -1,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 5.5,
                                                vertical: 1.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.posOrange
                                                    : AppColors.textDarkSlate,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Text(
                                                '$itemCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      shortName,
                                      style: TextStyle(
                                        fontSize: 11.8,
                                        fontWeight: isSelected
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.posOrange
                                            : AppColors.textDarkSlate,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 220),
                                      width: isSelected ? 14 : 0,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: AppColors.posOrange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Header Katalog Unggulan + Lihat Semua (Persis Video 2)
                      SmoothStaggeredReveal(
                        index: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.posOrange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'Katalog Unggulan UMKM (${products.length})',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDarkSlate,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => widget.onSwitchTab?.call(1),
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Lihat Semua',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.posOrange,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 11,
                                      color: AppColors.posOrange,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // 5. GRID 2 KOLOM PRODUK MUNCUL PERLAHAN SATU PER SATU (STAGGERED SMOOTH REVEAL)
              if (productProvider.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.posOrange,
                      ),
                    ),
                  ),
                )
              else if (products.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(
                      child: Text(
                        'Tidak ada produk yang cocok dengan kategori/pencarian.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final prod = products[index];
                        return SmoothStaggeredReveal(
                          key: ValueKey(
                            'dash_card_${prod.id}_${_categoryAnimVersion}_${productProvider.catalogVersion}',
                          ),
                          index: index + 3,
                          baseDelay: const Duration(milliseconds: 80),
                          stepDelay: const Duration(milliseconds: 95),
                          duration: const Duration(milliseconds: 720),
                          child: ProductCard(
                            product: prod,
                            onTapDetail: () => _openProductSwipeDetail(prod),
                            onTapAddToCart: () => _openQuickAddSheet(prod),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),

              // 6. SEKSI STATISTIK KPI & GRAFIK PENJUALAN MUNCUL PERLAHAN
              SliverToBoxAdapter(
                child: SmoothStaggeredReveal(
                  index: 8,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Statistik & Analitik UMKM',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDarkSlate,
                              ),
                            ),
                            if (auth.isAdmin)
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CategoryManagementScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Kelola Kategori',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.loginPrimaryGreen,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.15,
                          children: [
                            StatCard(
                              title: 'Penjualan Hari Ini',
                              value: CurrencyFormatter.formatCompactRupiah(
                                txProvider.todaySalesTotal,
                              ),
                              subtitle:
                                  '${txProvider.todayTransactionsCount} Transaksi',
                              icon: Icons.payments_rounded,
                              accentColor: AppColors.loginPrimaryGreen,
                            ),
                            StatCard(
                              title: 'Total Produk',
                              value:
                                  '${productProvider.totalProductsCount} Item',
                              subtitle: '${categories.length} Kategori',
                              icon: Icons.inventory_2_rounded,
                              accentColor: AppColors.posOrange,
                            ),
                            StatCard(
                              title: 'Total Stok Gudang',
                              value: '${productProvider.totalStockUnits} Unit',
                              subtitle: 'Siap Jual',
                              icon: Icons.warehouse_rounded,
                              accentColor: AppColors.primaryIndigo,
                            ),
                            StatCard(
                              title: 'Stok Menipis',
                              value: '${lowStockList.length} Produk',
                              subtitle: 'Perlu Restock (<=10)',
                              icon: Icons.warning_amber_rounded,
                              accentColor: AppColors.warningAmber,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildSalesChartCard(),

                        if (lowStockList.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Peringatan Stok Menipis',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...lowStockList.take(3).map(
                                (item) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.warningAmber
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: AppColors.warningAmber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              'SKU: ${item.sku} • Tersisa ${item.stock} unit',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            _openProductSwipeDetail(item),
                                        child: const Text(
                                          'Detail',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ],
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

  Widget _buildSalesChartCard() {
    final Map<String, List<Map<String, dynamic>>> chartData = {
      'Harian': [
        {'label': '08:00', 'ratio': 0.35, 'val': '85k'},
        {'label': '10:00', 'ratio': 0.65, 'val': '140k'},
        {'label': '12:00', 'ratio': 0.92, 'val': '245k'},
        {'label': '15:00', 'ratio': 0.58, 'val': '120k'},
        {'label': '18:00', 'ratio': 0.80, 'val': '195k'},
        {'label': '20:00', 'ratio': 0.45, 'val': '95k'},
      ],
      'Mingguan': [
        {'label': 'Sen', 'ratio': 0.52, 'val': '420k'},
        {'label': 'Sel', 'ratio': 0.68, 'val': '560k'},
        {'label': 'Rab', 'ratio': 0.60, 'val': '490k'},
        {'label': 'Kam', 'ratio': 0.78, 'val': '640k'},
        {'label': 'Jum', 'ratio': 0.90, 'val': '780k'},
        {'label': 'Sab', 'ratio': 1.0, 'val': '920k'},
        {'label': 'Min', 'ratio': 0.84, 'val': '710k'},
      ],
      'Bulanan': [
        {'label': 'Mgg 1', 'ratio': 0.65, 'val': '3.2Jt'},
        {'label': 'Mgg 2', 'ratio': 0.82, 'val': '4.1Jt'},
        {'label': 'Mgg 3', 'ratio': 0.74, 'val': '3.7Jt'},
        {'label': 'Mgg 4', 'ratio': 0.96, 'val': '4.9Jt'},
      ],
    };

    final points = chartData[_selectedChartPeriod] ?? chartData['Mingguan']!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grafik Penjualan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDarkSlate,
                ),
              ),
              Row(
                children: ['Harian', 'Mingguan', 'Bulanan'].map((period) {
                  final active = _selectedChartPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedChartPeriod = period);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.posOrange
                              : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color:
                                active ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 118,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: points.map((pt) {
                final double ratio = pt['ratio'] as double;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      pt['val'].toString(),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      width: 24,
                      height: 70 * ratio,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: ratio > 0.85
                              ? [
                                  AppColors.posOrange,
                                  AppColors.posOrangeDark,
                                ]
                              : [
                                  AppColors.loginPrimaryGreen,
                                  AppColors.loginAccentLime,
                                ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pt['label'].toString(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDarkSlate,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Strip Pill Ringkasan Cepat di Bawah Banner Beranda
  Widget _buildQuickPulsePill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 13,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.2,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDarkSlate,
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

  /// Ikon Lingkaran Khusus Kategori "Semua":
  /// Menampilkan Kolase 2x2 dari 4 Kategori Berbeda (Minuman, Makanan, Roti, Sembako)
  /// ditambah Lencana Tengah 3D Grid Oranye (Bukan gambar Burger tunggal!)
  Widget _buildAllCategoriesMosaicCircle(bool isSelected) {
    const mosaicThumbs = [
      'assets/produk/minuman_kopi_susu_gula_aren.jpg',
      'assets/produk/makanan_nasi_goreng_spesial.jpg',
      'assets/produk/roti_butter_croissant.jpg',
      'assets/produk/sembako_beras_premium.jpg',
    ];

    return ClipOval(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        mosaicThumbs[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 1.2),
                    Expanded(
                      child: Image.asset(
                        mosaicThumbs[1],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1.2),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        mosaicThumbs[2],
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 1.2),
                    Expanded(
                      child: Image.asset(
                        mosaicThumbs[3],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Overlay gelap lembut agar ikon Grid di tengah terlihat kontras & mewah
          Container(
            color: Colors.black.withValues(alpha: isSelected ? 0.18 : 0.26),
          ),
          Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? const [Color(0xFFFF8A3D), AppColors.posOrange]
                      : const [Color(0xFF1E293B), Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x45000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: Colors.white,
                size: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
