import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/stat_card.dart';
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
  String _selectedChartPeriod = 'Mingguan'; // 'Harian', 'Mingguan', 'Bulanan'

  void _openProductSwipeDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailSwipeScreen(initialProduct: product),
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

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('minum') || lower.contains('kopi')) {
      return Icons.local_cafe_rounded;
    }
    if (lower.contains('ringan') || lower.contains('camilan')) {
      return Icons.cookie_rounded;
    }
    if (lower.contains('roti') || lower.contains('bakery')) {
      return Icons.bakery_dining_rounded;
    }
    if (lower.contains('sembako')) {
      return Icons.rice_bowl_rounded;
    }
    return Icons.shopping_bag_rounded;
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
            await Future.wait([
              productProvider.loadProducts(),
              categoryProvider.loadCategories(),
              txProvider.loadTransactions(),
            ]);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. HEADER ATAS PERSIS VIDEO 2 (KONSEP SETELAH LOGIN.mp4 — "Bonjour, Ayoub")
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.posOrange,
                                  AppColors.posOrangeDark,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              (user?.fullName.isNotEmpty == true)
                                  ? user!.fullName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bonjour, ${user?.fullName.split(' ').first ?? 'Andriyan'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDarkSlate,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${user?.isAdmin == true ? 'Admin Utama' : 'Kasir Aktif'} • UMKM Cloud',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
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
                          if (auth.isAdmin)
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductFormScreen(),
                                  ),
                                );
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.posOrangeLight,
                              ),
                              icon: const Icon(
                                Icons.add_rounded,
                                color: AppColors.posOrange,
                                size: 20,
                              ),
                              tooltip: 'Tambah Produk',
                            ),
                          const SizedBox(width: 6),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 20,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 2. HERO HEADLINE DUA WARNA PERSIS VIDEO 2 ("Une envie ? On livre.")
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                          children: [
                            TextSpan(
                              text: 'Ada pesanan ? ',
                              style: TextStyle(color: AppColors.textDarkSlate),
                            ),
                            TextSpan(
                              text: 'Layani Cepat.',
                              style: TextStyle(color: AppColors.posOrange),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 3. SEARCH BAR KAPSUL + TOMBOL ORANYE KANAN PERSIS VIDEO 2
                      Container(
                        height: 48,
                        padding: const EdgeInsets.only(left: 18, right: 5),
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
                                onChanged: productProvider.setSearchQuery,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Rechercher / Cari produk, SKU...',
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

                      const SizedBox(height: 16),

                      // 4. HORIZONTAL CATEGORY CAROUSEL BULAT PERSIS VIDEO 2
                      SizedBox(
                        height: 86,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: categories.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final isAll = index == 0;
                            final catId =
                                isAll ? 'all' : categories[index - 1].id;
                            final catName = isAll
                                ? 'Semua'
                                : categories[index - 1].name.split(' ').first;
                            final isSelected =
                                productProvider.selectedCategoryId == catId;

                            return GestureDetector(
                              onTap: () =>
                                  productProvider.setCategoryFilter(catId),
                              child: Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.posOrangeLight
                                          : const Color(0xFFF3F1ED),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.posOrange
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      isAll
                                          ? Icons.apps_rounded
                                          : _getCategoryIcon(catName),
                                      color: isSelected
                                          ? AppColors.posOrange
                                          : const Color(0xFF64748B),
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    catName,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
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

                      const SizedBox(height: 10),

                      // Header Katalog Pilihan (Klik kartu untuk Video 3 Swipe Detail, Klik '+' untuk Video 2 Sheet)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Katalog Unggulan UMKM',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                          TextButton(
                            onPressed: () => widget.onSwitchTab?.call(1),
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.posOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 5. GRID 2 KOLOM PRODUK PERSIS VIDEO 2 (Smash Burger / Pizza / Cappuccino style)
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
                        'Tidak ada produk yang cocok dengan pencarian.',
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
                      childAspectRatio: 0.76,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final prod = products[index];
                        return ProductCard(
                          product: prod,
                          onTapDetail: () => _openProductSwipeDetail(prod),
                          onTapAddToCart: () => _openQuickAddSheet(prod),
                        );
                      },
                      childCount: products.length > 6 ? 6 : products.length,
                    ),
                  ),
                ),

              // 6. SEKSI STATISTIK KPI, GRAFIK PENJUALAN & AKTIVITAS INVENTARIS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ringkasan Bisnis & Inventaris',
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

                      // Grid 6 Statistik Utama
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
                            value: '${productProvider.totalProductsCount} Item',
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

                      // Grafik Penjualan Interaktif (Harian / Mingguan / Bulanan)
                      _buildSalesChartCard(),

                      const SizedBox(height: 16),

                      // Peringatan Stok Menipis
                      if (lowStockList.isNotEmpty) ...[
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
