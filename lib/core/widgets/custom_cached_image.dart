import 'dart:convert';
import 'dart:typed_data';
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

  static Uint8List? tryDecodeDataUri(String uri) {
    if (!uri.startsWith('data:image/')) return null;
    final commaIdx = uri.indexOf(',');
    if (commaIdx == -1 || commaIdx + 1 >= uri.length) return null;
    try {
      return base64Decode(uri.substring(commaIdx + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    final trimmed = imageUrl.trim();

    if (trimmed.isEmpty) {
      return _buildFallback(radius);
    }

    final memoryBytes = tryDecodeDataUri(trimmed);
    if (memoryBytes != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.memory(
          memoryBytes,
          width: width,
          height: height,
          fit: fit,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => _buildFallback(radius),
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        trimmed,
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

class CustomAvatarImage extends StatelessWidget {
  final String avatarUrl;
  final String fullName;
  final double size;

  const CustomAvatarImage({
    super.key,
    required this.avatarUrl,
    required this.fullName,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = avatarUrl.trim();
    final initial =
        fullName.trim().isNotEmpty ? fullName.trim()[0].toUpperCase() : 'A';

    if (trimmed.isEmpty) {
      return _buildInitialCircle(initial);
    }

    final memoryBytes = CustomProductImage.tryDecodeDataUri(trimmed);
    if (memoryBytes != null) {
      return ClipOval(
        child: Image.memory(
          memoryBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialCircle(initial),
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        trimmed,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitialCircle(initial),
      ),
    );
  }

  Widget _buildInitialCircle(String initial) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.posOrange, AppColors.posOrangeDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
