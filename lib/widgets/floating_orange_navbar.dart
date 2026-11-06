import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FloatingOrangeNavbar extends StatelessWidget {
  final int currentIndex;
  final int cartBadgeCount;
  final ValueChanged<int> onTap;

  const FloatingOrangeNavbar({
    super.key,
    required this.currentIndex,
    required this.cartBadgeCount,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.home_rounded, label: 'Beranda'),
    _NavItemData(icon: Icons.grid_view_rounded, label: 'Katalog'),
    _NavItemData(icon: Icons.point_of_sale_rounded, label: 'Kasir'),
    _NavItemData(icon: Icons.receipt_long_rounded, label: 'Riwayat'),
    _NavItemData(icon: Icons.bar_chart_rounded, label: 'Laporan'),
    _NavItemData(icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.posOrange, AppColors.posOrangeDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4DF05A28),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = currentIndex == index;
          final showBadge = index == 2 && cartBadgeCount > 0;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 12 : 9,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: isSelected ? AppColors.posOrange : Colors.white,
                      ),
                      if (showBadge)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.loginPrimaryGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$cartBadgeCount',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.posOrange,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: AppColors.posOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({required this.icon, required this.label});
}

