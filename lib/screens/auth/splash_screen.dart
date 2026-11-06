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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.65, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1650), () {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lingkaran hijau lembut + ilustrasi skuter/toko (Persis Video 1 detik 00:02)
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: 158,
                  height: 158,
                  decoration: const BoxDecoration(
                    color: AppColors.loginSoftMint,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 118,
                        height: 118,
                        decoration: BoxDecoration(
                          color: AppColors.loginPrimaryGreen.withValues(
                            alpha: 0.14,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(
                        Icons.delivery_dining_rounded,
                        size: 88,
                        color: AppColors.loginPrimaryGreen,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tipografi dua warna persis "Foodie." di Video 1 -> "CloudPOS."
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
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
                'Smart inventory, fast cashier for UMKM',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

