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
      duration: const Duration(milliseconds: 1250),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Lingkaran hijau membesar halus
    _circleScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _rideController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    // Skuter meluncur dari kiri luar layar ke tengah (Persis KONSEP LOGIN.mp4 00:01-00:03)
    _scooterSlide = Tween<Offset>(
      begin: const Offset(-1.45, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _rideController,
        curve: const Interval(0.10, 0.78, curve: Curves.easeOutBack),
      ),
    );

    // Teks CloudPOS. muncul dari bawah
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rideController,
        curve: const Interval(0.45, 0.95, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _rideController,
        curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _rideController.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
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
            // Ilustrasi Skuter Kurir + Lingkaran Mint (Persis Video 1 detik 00:01 - 00:04)
            SizedBox(
              width: 220,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: _circleScale,
                    child: Container(
                      width: 172,
                      height: 172,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF5E4),
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
                            math.sin(_floatController.value * math.pi) * -5.0;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        );
                      },
                      child: const CloudPosScooterIllustration(size: 155),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Nama Aplikasi Kita: CloudPOS. (Bukan Foodie!)
            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _textSlide,
                child: Column(
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.1,
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
                    const SizedBox(height: 6),
                    const Text(
                      'Cloud Inventory & POS UMKM Modern',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
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

/// Ilustrasi Vektor Berlapis Skuter Kurir Hijau khas Video 1 (KONSEP LOGIN.mp4)
class CloudPosScooterIllustration extends StatelessWidget {
  final double size;

  const CloudPosScooterIllustration({
    super.key,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bayangan bawah skuter
          Positioned(
            bottom: size * 0.10,
            child: Container(
              width: size * 0.72,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF2E5B18).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Box Kargo Belakang bertuliskan POS
          Positioned(
            left: size * 0.08,
            top: size * 0.28,
            child: Transform.rotate(
              angle: -0.06,
              child: Container(
                width: size * 0.30,
                height: size * 0.26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3E7622), Color(0xFF2E5B18)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBEF264), width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'POS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          // Ikon Utama Skuter Berlapis
          Positioned(
            bottom: size * 0.08,
            right: size * 0.06,
            child: Icon(
              Icons.two_wheeler_rounded,
              size: size * 0.76,
              color: const Color(0xFF4E8D2A),
            ),
          ),
          // Karakter Kurir / Helm Hijau Muda
          Positioned(
            top: size * 0.14,
            left: size * 0.36,
            child: Container(
              width: size * 0.24,
              height: size * 0.24,
              decoration: BoxDecoration(
                color: const Color(0xFF84CC16),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: size * 0.13,
                color: Colors.white,
              ),
            ),
          ),
          // Garis kecepatan angin
          Positioned(
            left: 2,
            bottom: size * 0.26,
            child: Container(
              width: size * 0.16,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF84CC16),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
