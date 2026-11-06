import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../categories/category_management_screen.dart';
import '../pos/quick_add_sheet.dart';
import 'product_detail_swipe_screen.dart';
import 'product_form_screen.dart';

class ProductCatalogScreen extends StatelessWidget {
  const ProductCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final products = productProvider.filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Katalog + Tombol Admin (Kategori & +Produk)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Katalog & Inventaris',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDarkSlate,
                          ),
                        ),
                        Text(
                          'Ketuk produk untuk Swipe Detail (Video 3)',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAdmin) ...[
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryManagementScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.category_outlined,
                        color: AppColors.textDarkSlate,
                      ),
                      tooltip: 'Kelola Kategori',
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductFormScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.posOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text(
                        'Produk',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Search Bar & Sorting / Filter Stok
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: productProvider.setSearchQuery,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Cari nama produk atau SKU...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Menu Sorting Harga & Nama
                  PopupMenuButton<ProductSortOption>(
                    onSelected: productProvider.setSortOption,
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: ProductSortOption.newest,
                        child: Text('Terbaru'),
                      ),
                      PopupMenuItem(
                        value: ProductSortOption.priceAsc,
                        child: Text('Harga: Termurah'),
                      ),
                      PopupMenuItem(
                        value: ProductSortOption.priceDesc,
                        child: Text('Harga: Termahal'),
                      ),
                      PopupMenuItem(
                        value: ProductSortOption.nameAsc,
                        child: Text('Nama: A - Z'),
                      ),
                      PopupMenuItem(
                        value: ProductSortOption.nameDesc,
                        child: Text('Nama: Z - A'),
                      ),
                    ],
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(
                        Icons.sort_rounded,
                        size: 20,
                        color: AppColors.textDarkSlate,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Filter Kategori Horizontal Chips
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  _buildFilterChip(
                    label: 'Semua Kategori',
                    selected: productProvider.selectedCategoryId == 'all',
                    onTap: () => productProvider.setCategoryFilter('all'),
                  ),
                  ...categoryProvider.categories.map(
                    (cat) => _buildFilterChip(
                      label: cat.name,
                      selected: productProvider.selectedCategoryId == cat.id,
                      onTap: () => productProvider.setCategoryFilter(cat.id),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Filter Status Stok
            SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  _buildStockChip(
                    label: 'Semua Stok',
                    selected:
                        productProvider.stockFilter == StockFilterOption.all,
                    onTap: () =>
                        productProvider.setStockFilter(StockFilterOption.all),
                  ),
                  _buildStockChip(
                    label: 'Tersedia',
                    selected: productProvider.stockFilter ==
                        StockFilterOption.available,
                    onTap: () => productProvider
                        .setStockFilter(StockFilterOption.available),
                  ),
                  _buildStockChip(
                    label: 'Stok Menipis (<=10)',
                    selected: productProvider.stockFilter ==
                        StockFilterOption.lowStock,
                    onTap: () => productProvider
                        .setStockFilter(StockFilterOption.lowStock),
                  ),
                  _buildStockChip(
                    label: 'Stok Habis',
                    selected: productProvider.stockFilter ==
                        StockFilterOption.outOfStock,
                    onTap: () => productProvider
                        .setStockFilter(StockFilterOption.outOfStock),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Grid Produk Responsive
            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text(
                        'Produk tidak ditemukan.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.76,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final prod = products[index];
                        return ProductCard(
                          product: prod,
                          onTapDetail: () =>
                              _openDetail(context, prod),
                          onTapAddToCart: () =>
                              _openQuickAdd(context, prod),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailSwipeScreen(initialProduct: product),
      ),
    );
  }

  void _openQuickAdd(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddProductSheet(product: product),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.posOrange : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.posOrange : AppColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textDarkSlate,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.loginSoftMint
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.loginPrimaryGreen
                  : AppColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: selected
                  ? AppColors.loginHeaderDarkGreen
                  : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
