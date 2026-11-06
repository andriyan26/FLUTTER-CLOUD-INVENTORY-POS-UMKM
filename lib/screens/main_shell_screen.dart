import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/floating_orange_navbar.dart';
import 'dashboard/dashboard_screen.dart';
import 'pos/pos_screen.dart';
import 'products/product_catalog_screen.dart';
import 'reports/sales_report_screen.dart';
import 'settings/settings_screen.dart';
import 'transactions/transaction_history_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CategoryProvider>().loadCategories();
      context.read<ProductProvider>().loadProducts();
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  void _onSelectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildActivePage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          key: const ValueKey('page_dashboard'),
          onSwitchTab: _onSelectTab,
        );
      case 1:
        return const ProductCatalogScreen(key: ValueKey('page_catalog'));
      case 2:
        return const PosScreen(key: ValueKey('page_pos'));
      case 3:
        return const TransactionHistoryScreen(key: ValueKey('page_history'));
      case 4:
        return const SalesReportScreen(key: ValueKey('page_reports'));
      case 5:
      default:
        return const SettingsScreen(key: ValueKey('page_settings'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalItemsCount;
    final user = context.watch<AuthProvider>().currentUser;

    final animatedPage = AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.0, 0.04),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: _buildActivePage(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 720;

        if (isWideScreen) {
          final isDesktopFull = constraints.maxWidth >= 980;
          return Scaffold(
            backgroundColor: const Color(0xFFFAF9F6),
            body: Row(
              children: [
                Container(
                  width: isDesktopFull ? 235 : 78,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: isDesktopFull
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.posOrange,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            if (isDesktopFull) ...[
                              const SizedBox(width: 10),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Cloud',
                                      style: TextStyle(
                                        color: AppColors.textDarkSlate,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'POS.',
                                      style: TextStyle(
                                        color: AppColors.posOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: [
                            _buildSidebarItem(
                              index: 0,
                              icon: Icons.home_rounded,
                              label: 'Dashboard',
                              expanded: isDesktopFull,
                            ),
                            _buildSidebarItem(
                              index: 1,
                              icon: Icons.grid_view_rounded,
                              label: 'Katalog Produk',
                              expanded: isDesktopFull,
                            ),
                            _buildSidebarItem(
                              index: 2,
                              icon: Icons.point_of_sale_rounded,
                              label: 'Kasir / POS',
                              badge: cartCount,
                              expanded: isDesktopFull,
                            ),
                            _buildSidebarItem(
                              index: 3,
                              icon: Icons.receipt_long_rounded,
                              label: 'Riwayat Transaksi',
                              expanded: isDesktopFull,
                            ),
                            _buildSidebarItem(
                              index: 4,
                              icon: Icons.bar_chart_rounded,
                              label: 'Laporan Bisnis',
                              expanded: isDesktopFull,
                            ),
                            _buildSidebarItem(
                              index: 5,
                              icon: Icons.settings_outlined,
                              label: 'Pengaturan',
                              expanded: isDesktopFull,
                            ),
                          ],
                        ),
                      ),
                      if (isDesktopFull && user != null)
                        Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.loginPrimaryGreen,
                                child: Text(
                                  user.fullName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      user.role.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.loginPrimaryGreen,
                                        fontWeight: FontWeight.w800,
                                      ),
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
                Expanded(child: animatedPage),
              ],
            ),
          );
        }

        // iPhone 13 & Smartphone Layout
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F6),
          body: Stack(
            children: [
              Positioned.fill(child: animatedPage),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FloatingOrangeNavbar(
                  currentIndex: _selectedIndex,
                  cartBadgeCount: cartCount,
                  onTap: _onSelectTab,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String label,
    required bool expanded,
    int badge = 0,
  }) {
    final selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _onSelectTab(index),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.posOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment:
                expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
              if (expanded) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textDarkSlate,
                    ),
                  ),
                ),
                if (badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selected ? Colors.white : AppColors.loginPrimaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: selected ? AppColors.posOrange : Colors.white,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
