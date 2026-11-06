import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget Logo Ciri Khas Utama Aplikasi "CloudPOS" (Signature Brand Identity)
/// Menggabungkan:
/// 1) Perisai 3D Squircle Berlapis (Sunset Orange -> Flame Coral) dengan Bevel Kaca & Kilau Emas
/// 2) Simbol Tas Belanja POS Modern + Siluet Awan Cloud di dalamnya + Senyum Ramah UMKM
/// 3) Bintang Mahkota Keemasan (Golden Crown Sparkle) & Lencana Hijau Cloud Sync
class CloudPosEmblemIcon extends StatefulWidget {
  final double size;
  final bool animate;
  final bool showCrownBadge;

  const CloudPosEmblemIcon({
    super.key,
    this.size = 48,
    bool? animate,
    bool? animatePulse,
    bool? showCrownBadge,
    bool? showBadge,
  })  : animate = animate ?? animatePulse ?? true,
        showCrownBadge = showCrownBadge ?? showBadge ?? true;

  @override
  State<CloudPosEmblemIcon> createState() => _CloudPosEmblemIconState();
}

class _CloudPosEmblemIconState extends State<CloudPosEmblemIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _shimmerController;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3400),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final ctrl = _shimmerController;

    if (ctrl == null) {
      return SizedBox(
        width: s,
        height: s,
        child: CustomPaint(
          painter: _CloudPosEmblemPainter(
            shimmerPhase: 0.25,
            showCrownBadge: widget.showCrownBadge,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final floatY = math.sin(ctrl.value * math.pi * 2) * (s * 0.025);
        return Transform.translate(
          offset: Offset(0, floatY),
          child: SizedBox(
            width: s,
            height: s,
            child: CustomPaint(
              painter: _CloudPosEmblemPainter(
                shimmerPhase: ctrl.value,
                showCrownBadge: widget.showCrownBadge,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget Kombinasi Logo Emblem + Tipografi Ciri Khas "CloudPOS"
class CloudPosBrandHeaderBadge extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool darkTheme;
  final String? subtitle;

  const CloudPosBrandHeaderBadge({
    super.key,
    this.iconSize = 36,
    this.fontSize = 18,
    this.darkTheme = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final primaryTextColor =
        darkTheme ? Colors.white : AppColors.textDarkSlate;
    final subtitleColor = darkTheme
        ? Colors.white.withValues(alpha: 0.72)
        : AppColors.textMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CloudPosEmblemIcon(
          size: iconSize,
          animate: true,
        ),
        SizedBox(width: iconSize * 0.24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cloud',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: primaryTextColor,
                    letterSpacing: -0.6,
                    height: 1.05,
                  ),
                ),
                Text(
                  'POS',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: AppColors.posOrange,
                    letterSpacing: -0.6,
                    height: 1.05,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 4, bottom: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A3D), Color(0xFFF05A28)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (fontSize * 0.42).clamp(7.5, 10.0),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: (fontSize * 0.56).clamp(9.5, 12.0),
                  fontWeight: FontWeight.w700,
                  color: subtitleColor,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CloudPosEmblemPainter extends CustomPainter {
  final double shimmerPhase;
  final bool showCrownBadge;

  _CloudPosEmblemPainter({
    required this.shimmerPhase,
    required this.showCrownBadge,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Rect.fromLTWH(0, 0, w, h);
    final radius = Radius.circular(w * 0.30);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    // 1. Bayangan luar lembut berdimensi 3D
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.10, w * 0.88, h * 0.86),
        radius,
      ),
      Paint()
        ..color = const Color(0xFFEA580C).withValues(alpha: 0.42)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.12),
    );

    // 2. Perisai Squircle Utama dengan Gradasi 3D (Warm Gold-Orange -> Deep Coral Flame)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF9248),
          Color(0xFFF05A28),
          Color(0xFFC8320E),
        ],
        stops: [0.0, 0.55, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRRect(rrect, bgPaint);

    // 3. Highlight Kaca Bagian Atas-Kiri (3D Glass Specular Rim)
    final innerRect = Rect.fromLTWH(w * 0.04, h * 0.04, w * 0.92, h * 0.92);
    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(w * 0.27),
    );
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.028
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.62),
            Colors.white.withValues(alpha: 0.10),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(innerRect),
    );

    // 4. Pegangan Tas Belanja Melengkung di Atas
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.068
      ..strokeCap = StrokeCap.round;
    final handleRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.34),
      width: w * 0.28,
      height: h * 0.26,
    );
    canvas.drawArc(handleRect, math.pi, math.pi, false, handlePaint);

    // 5. Bodi Tas Belanja 3D Putih Bersih di Tengah
    final bagRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.21, h * 0.33, w * 0.58, h * 0.47),
      topLeft: Radius.circular(w * 0.10),
      topRight: Radius.circular(w * 0.10),
      bottomLeft: Radius.circular(w * 0.16),
      bottomRight: Radius.circular(w * 0.16),
    );
    canvas.drawRRect(
      bagRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Colors.white, Color(0xFFFFF4EC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bagRect.outerRect),
    );

    // 6. Ikon Awan Cloud + Senyum POS Oranye di Dalam Tas Belanja (Ciri Khas CloudPOS!)
    final cloudColor = const Color(0xFFF05A28);
    final cloudPaint = Paint()..color = cloudColor;

    // Tiga bulatan awan menyatu di bagian tengah tas
    canvas.drawCircle(Offset(w * 0.41, h * 0.52), w * 0.068, cloudPaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.48), w * 0.085, cloudPaint);
    canvas.drawCircle(Offset(w * 0.59, h * 0.52), w * 0.064, cloudPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.36, h * 0.51, w * 0.28, h * 0.075),
        Radius.circular(w * 0.04),
      ),
      cloudPaint,
    );

    // Garis lengkung senyum ramah di bawah awan
    final smilePaint = Paint()
      ..color = const Color(0xFFD9381E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.042
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.62),
        width: w * 0.22,
        height: h * 0.11,
      ),
      0.18,
      math.pi - 0.36,
      false,
      smilePaint,
    );

    // 7. Kilau Shimmer Diagonal Bergerak Halus di Atas Emblem
    canvas.save();
    canvas.clipRRect(rrect);
    final shimmerX = -w * 0.6 + (shimmerPhase * w * 2.2);
    final shimmerPath = Path()
      ..moveTo(shimmerX, 0)
      ..lineTo(shimmerX + w * 0.28, 0)
      ..lineTo(shimmerX - w * 0.12, h)
      ..lineTo(shimmerX - w * 0.40, h)
      ..close();
    canvas.drawPath(
      shimmerPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.24),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );
    canvas.restore();

    // 8. Lencana Bintang Emas / Cloud Sync Hijau di Sudut Kanan Bawah
    if (showCrownBadge) {
      final badgeCenter = Offset(w * 0.80, h * 0.80);
      canvas.drawCircle(
        badgeCenter,
        w * 0.15,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        badgeCenter,
        w * 0.125,
        Paint()..color = AppColors.loginPrimaryGreen,
      );
      // Tanda centang putih di dalam lencana hijau
      final checkPath = Path()
        ..moveTo(badgeCenter.dx - w * 0.05, badgeCenter.dy)
        ..lineTo(badgeCenter.dx - w * 0.01, badgeCenter.dy + h * 0.04)
        ..lineTo(badgeCenter.dx + w * 0.055, badgeCenter.dy - h * 0.035);
      canvas.drawPath(
        checkPath,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.032
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPosEmblemPainter oldDelegate) =>
      oldDelegate.shimmerPhase != shimmerPhase ||
      oldDelegate.showCrownBadge != showCrownBadge;
}

