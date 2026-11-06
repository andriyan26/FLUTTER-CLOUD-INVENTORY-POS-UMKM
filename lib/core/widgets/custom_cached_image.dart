import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String fallbackLabel;

  const CustomProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackLabel = 'UMKM',
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    if (imageUrl.trim().isEmpty) {
      return _buildFallback(radius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: radius,
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.posOrange,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(radius);
        },
      ),
    );
  }

  Widget _buildFallback(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3EE), Color(0xFFFDE6DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_mall_rounded,
            color: AppColors.posOrange,
            size: 32,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              fallbackLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.posOrangeDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

