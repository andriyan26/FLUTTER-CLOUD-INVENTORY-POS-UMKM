import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
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
import '../pos/quick_add_sheet.dart';
import '../products/product_detail_swipe_screen.dart';
import '../products/product_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onSwitchTab;

  const DashboardScreen({
    super.key,
    this.onSwitchTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedChartPeriod = 'Mingguan';
  int _categoryAnimVersion = 0;
  bool _showWaveBanner = false;

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
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.posOrange,
                                      AppColors.loginPrimaryGreen,
                                    ],
                                  ),
                                  boxShadow: const [
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
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => widget.onSwitchTab?.call(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjour, ${user?.fullName.split(' ').first ?? 'Andriyan'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
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
                                                'CloudPOS • Cabang Utama',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11.5,
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
                            ElevatedButton.icon(
                              onPressed: () async {
                                final added = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductFormScreen(),
                                  ),
                                );
                                if (added == true && mounted) {
                                  setState(() => _categoryAnimVersion++);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.posOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 7,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 15),
                              label: const Text(
                                'Barang',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppColors.borderLight),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 20,
                                color: AppColors.textDarkSlate,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 2. HERO HEADLINE + SEARCH BAR MUNCUL PERLAHAN (Persis Video 2)
                      SmoothStaggeredReveal(
                        index: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 25,
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
                            const SizedBox(height: 12),
                            Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.only(left: 18, right: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: const Color(0xFFEDEFF2),
                                  width: 1.2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x080F172A),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
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
                                          fontSize: 13,
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
                                      color: AppColors.posOrange,
                                      shape: BoxShape.circle,
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

                      // 3. PROMO BANNER MEWAH HIJAU (Persis KONSEP LOGIN.mp4 detik 00:15 setelah login!)
                      SmoothStaggeredReveal(
                        index: 2,
                        child: Container(
                          height: 108,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF285214),
                                Color(0xFF4E8D2A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x30285214),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const CloudPosScooterIllustration(size: 82),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'FAST & CLOUD POS',
                                      style: TextStyle(
                                        color: Color(0xFFBEF264),
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    const Text(
                                      'Kelola stok & transaksi kasir real-time',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    GestureDetector(
                                      onTap: () =>
                                          widget.onSwitchTab?.call(2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.posOrange,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Text(
                                          'BUKA KASIR SEKARANG',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 4. HORIZONTAL CATEGORY CAROUSEL BULAT BERGAMBAR (Persis Video 2 detik 00:03-00:08)
                      SmoothStaggeredReveal(
                        index: 3,
                        child: SizedBox(
                          height: 92,
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
                                  ? 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=300&q=80'
                                  : CategoryService.getCategoryThumbnail(
                                      fullCatName,
                                    );

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
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 240),
                                        width: 62,
                                        height: 62,
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.posOrangeLight
                                              : const Color(0xFFF3EFEA),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.posOrange
                                                : Colors.transparent,
                                            width: 2.2,
                                          ),
                                          boxShadow: isSelected
                                              ? const [
                                                  BoxShadow(
                                                    color: Color(0x33F05A28),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: CustomProductImage(
                                          imageUrl: thumbUrl,
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          fallbackLabel: shortName,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      shortName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w900
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.posOrange
                                            : AppColors.textMuted,
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

                      // Header Katalog Unggulan + Tombol Cepat Tambah Barang
                      SmoothStaggeredReveal(
                        index: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Katalog Unggulan (${products.length} Barang)',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDarkSlate,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                final added = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductFormScreen(),
                                  ),
                                );
                                if (added == true && mounted) {
                                  setState(() => _categoryAnimVersion++);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle_rounded,
                                      size: 15,
                                      color: AppColors.posOrange,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tambah Barang Baru',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.posOrange,
                                      ),
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
}
