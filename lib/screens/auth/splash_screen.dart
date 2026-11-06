import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rideController;
  late final AnimationController _floatController;
  late final Animation<Offset> _scooterSlide;
  late final Animation<double> _circleScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _rideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rideController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _scooterSlide = Tween<Offset>(
      begin: const Offset(-1.55, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _rideController,
        curve: const Interval(0.12, 0.82, curve: Curves.easeOutBack),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rideController,
        curve: const Interval(0.48, 1.0, curve: Curves.easeOutQuart),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _rideController,
        curve: const Interval(0.48, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    _rideController.forward();

    Future.delayed(const Duration(milliseconds: 2450), () {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _rideController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 230,
              height: 210,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: _circleScale,
                    child: Container(
                      width: 178,
                      height: 178,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFD9F99D).withValues(alpha: 0.55),
                            const Color(0xFFEAF5E4),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SlideTransition(
                    position: _scooterSlide,
                    child: AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        final dy =
                            math.sin(_floatController.value * math.pi) * -5.5;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        );
                      },
                      child: const CloudPosScooterIllustration(size: 168),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _textSlide,
                child: Column(
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                        ),
                        children: [
                          TextSpan(
                            text: 'Cloud',
                            style: TextStyle(color: AppColors.textDarkSlate),
                          ),
                          TextSpan(
                            text: 'POS.',
                            style: TextStyle(color: AppColors.loginPrimaryGreen),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Smart inventory, delivered fast',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ilustrasi Vektor Custom-Painted Kurir Skuter Hijau (Persis Karakter di KONSEP LOGIN.mp4)
class CloudPosScooterIllustration extends StatelessWidget {
  final double size;

  const CloudPosScooterIllustration({
    super.key,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ScooterMascotPainter(),
      ),
    );
  }
}

class _ScooterMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Bayangan bawah skuter
    final shadowPaint = Paint()
      ..color = const Color(0xFF1E3A10).withValues(alpha: 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.87),
        width: w * 0.74,
        height: h * 0.08,
      ),
      shadowPaint,
    );

    // 2. Asap kecepatan putih/mint di kiri belakang
    final puffPaint = Paint()
      ..color = const Color(0xFFBEF264).withValues(alpha: 0.65);
    canvas.drawCircle(Offset(w * 0.10, h * 0.72), w * 0.055, puffPaint);
    canvas.drawCircle(Offset(w * 0.16, h * 0.75), w * 0.04, puffPaint);

    // 3. Roda Belakang & Roda Depan
    final tirePaint = Paint()..color = const Color(0xFF1E242B);
    final rimPaint = Paint()..color = const Color(0xFFE2E8F0);
    final hubPaint = Paint()..color = const Color(0xFF4E8D2A);

    final rearWheelCenter = Offset(w * 0.28, h * 0.76);
    final frontWheelCenter = Offset(w * 0.74, h * 0.76);

    for (final center in [rearWheelCenter, frontWheelCenter]) {
      canvas.drawCircle(center, w * 0.115, tirePaint);
      canvas.drawCircle(center, w * 0.065, rimPaint);
      canvas.drawCircle(center, w * 0.028, hubPaint);
    }

    // 4. Boks Kargo Belakang Hijau Tua (Delivery Box)
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.36, w * 0.23, h * 0.22),
      Radius.circular(w * 0.04),
    );
    final boxPaint = Paint()..color = const Color(0xFF285214);
    canvas.drawRRect(boxRect, boxPaint);
    final boxStripePaint = Paint()..color = const Color(0xFFA3E635);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.12, h * 0.45, w * 0.23, h * 0.035),
      boxStripePaint,
    );

    // 5. Tubuh Karakter Kurir (Jaket Hijau & Kepala/Helm)
    final torsoPaint = Paint()..color = const Color(0xFF3E7622);
    final torsoPath = Path()
      ..moveTo(w * 0.36, h * 0.56)
      ..quadraticBezierTo(w * 0.37, h * 0.32, w * 0.48, h * 0.31)
      ..lineTo(w * 0.57, h * 0.45)
      ..lineTo(w * 0.46, h * 0.58)
      ..close();
    canvas.drawPath(torsoPath, torsoPaint);

    // Wajah & Helm Hijau Cerah
    final facePaint = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawCircle(Offset(w * 0.49, h * 0.23), w * 0.075, facePaint);

    final helmetPaint = Paint()..color = const Color(0xFF65A30D);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.48, h * 0.22), radius: w * 0.088),
      math.pi * 0.95,
      math.pi * 1.15,
      true,
      helmetPaint,
    );

    // 6. Bodi Skuter Vespa Hijau Muda & Dek Bawah
    final bodyPaint = Paint()..color = const Color(0xFF65A30D);
    final bodyPath = Path()
      ..moveTo(w * 0.16, h * 0.72)
      ..quadraticBezierTo(w * 0.20, h * 0.55, w * 0.44, h * 0.56)
      ..lineTo(w * 0.62, h * 0.70)
      ..lineTo(w * 0.71, h * 0.40)
      ..lineTo(w * 0.77, h * 0.42)
      ..quadraticBezierTo(w * 0.84, h * 0.58, w * 0.76, h * 0.73)
      ..lineTo(w * 0.16, h * 0.73)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Spakbor Depan & Jok Hitam
    final seatPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.31, h * 0.52, w * 0.19, h * 0.06),
        Radius.circular(w * 0.03),
      ),
      seatPaint,
    );

    // Lampu Depan Kuning Bersinar
    final lightPaint = Paint()..color = const Color(0xFFFEF08A);
    canvas.drawCircle(Offset(w * 0.76, h * 0.39), w * 0.038, lightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
