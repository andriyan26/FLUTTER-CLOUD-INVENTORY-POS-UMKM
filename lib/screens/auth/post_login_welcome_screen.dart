import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Layar Transisi Animasi Setelah Login Persis VIDEO 2 (KONSEP SETELAH LOGIN.mp4 detik 00:00 - 00:02)
/// Menggunakan Aset 3D Fotorealistis Multi-Layer:
/// 1) Latar Jalan Raya Kota Golden Hour (`assets/images/boulevard_clean.jpg`) dengan efek kamera dolly-in 3D,
///    sinar matahari keemasan, dan pejalan kaki di trotoar.
/// 2) Layer Kurir & Motor Skuter Oranye Tampak Belakang 3D (`assets/images/scooter_rider_3d.png`) yang
///    BERJALAN MAJU KE DEPAN-ATAS (`KE DEPAN ATAS`) mengikuti lengkungan lajur jalan raya dengan perspektif 3D,
///    getaran mesin halus, bayangan aspal dinamis, dan kepulan asap knalpot realistis!
/// 3) Tombol kapsul frosted-glass "Commencer" di bawah yang melebar menjadi tanda centang ganda (✓✓).
class PostLoginWelcomeScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const PostLoginWelcomeScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<PostLoginWelcomeScreen> createState() => _PostLoginWelcomeScreenState();
}

class _PostLoginWelcomeScreenState extends State<PostLoginWelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _driveLoopController;
  late final AnimationController _engineVibrationController;
  late final AnimationController _boostForwardController;
  Timer? _autoLaunchTimer;

  bool _isExpandingButton = false;
  bool _showDoubleCheck = false;

  @override
  void initState() {
    super.initState();

    // Animasi motor berjalan maju ke DEPAN-ATAS sepanjang lajur jalan raya
    _driveLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    // Getaran mesin & roda 60fps
    _engineVibrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..repeat();

    // Akselerasi maju ke depan-atas saat tombol "Commencer" ditekan
    _boostForwardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    // Beri waktu 4 detik agar pengguna menikmati animasi motor realistis berjalan ke depan-atas
    _autoLaunchTimer = Timer(const Duration(milliseconds: 4000), () {
      if (mounted && !_isExpandingButton) {
        _triggerLaunchTransition();
      }
    });
  }

  @override
  void dispose() {
    _autoLaunchTimer?.cancel();
    _driveLoopController.dispose();
    _engineVibrationController.dispose();
    _boostForwardController.dispose();
    super.dispose();
  }

  Future<void> _triggerLaunchTransition() async {
    if (_isExpandingButton) return;
    _autoLaunchTimer?.cancel();
    setState(() {
      _isExpandingButton = true;
    });
    _boostForwardController.forward();

    await Future.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;
    setState(() {
      _showDoubleCheck = true;
    });
    await Future.delayed(const Duration(milliseconds: 520));
    if (!mounted) return;
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E140F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. LAYER LATAR JALAN RAYA GOLDEN HOUR 3D REALISTIS + DOLLY ZOOM MAJU
          AnimatedBuilder(
            animation: Listenable.merge([
              _driveLoopController,
              _boostForwardController,
            ]),
            builder: (context, child) {
              final zoom = 1.0 +
                  (_driveLoopController.value * 0.05) +
                  (_boostForwardController.value * 0.08);
              return Transform.scale(
                scale: zoom,
                alignment: const Alignment(0.15, -0.12),
                child: child,
              );
            },
            child: Image.asset(
              'assets/images/boulevard_clean.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. EFEK ATMOSFER GOLDEN HOUR, MARKA JALAN MENGALIR & PEJALAN KAKI BERGERAK DI TROTOAR DEPAN
          AnimatedBuilder(
            animation: Listenable.merge([
              _driveLoopController,
              _engineVibrationController,
              _boostForwardController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _GoldenHourRoadMotionOverlayPainter(
                  driveProgress: _driveLoopController.value,
                  cyclePhase: _engineVibrationController.value,
                  boostProgress: _boostForwardController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // 3. LAYER UTAMA: KURIR MOTOR SKUTER ORANYE 3D REALISTIS TAMPAK BELAKANG
          //    BERJALAN MAJU KE DEPAN-ATAS (KE DEPAN ATAS) MENGIKUTI LAJUR JALAN RAYA!
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return AnimatedBuilder(
                animation: Listenable.merge([
                  _driveLoopController,
                  _engineVibrationController,
                  _boostForwardController,
                ]),
                builder: (context, scooterChild) {
                  final driveT = Curves.easeInOutSine.transform(
                    _driveLoopController.value,
                  );
                  final boostT = Curves.easeInCubic.transform(
                    _boostForwardController.value,
                  );

                  // Pergerakan perspektif 3D ke DEPAN-ATAS (mengikuti lengkungan jalan ke arah depan-atas)
                  final moveForwardX = (driveT * w * 0.09) + (boostT * w * 0.16);
                  final moveForwardUpY =
                      -(driveT * h * 0.075) - (boostT * h * 0.16);

                  // Getaran suspensi mesin 60fps
                  final engineBounceY = math.sin(
                        _engineVibrationController.value * math.pi * 2,
                      ) *
                      2.2;

                  // Skala mengecil secara perspektif saat motor semakin maju ke depan-atas jalan raya
                  final perspectiveScale =
                      (1.04 - (driveT * 0.18)) * (1.0 - (boostT * 0.34));

                  // Sedikit miring mengikuti belokan jalan ke depan
                  final roadBankAngle =
                      (driveT * 0.025) + (boostT * 0.035);

                  final baseLeft = w * 0.05 + moveForwardX;
                  final baseBottom = h * 0.14 - moveForwardUpY - engineBounceY;
                  final scooterWidth = w * 0.48;
                  final scooterHeight = scooterWidth * (550.0 / 315.0);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        left: baseLeft,
                        bottom: baseBottom,
                        width: scooterWidth,
                        height: scooterHeight,
                        child: Transform.scale(
                          scale: perspectiveScale,
                          alignment: Alignment.bottomCenter,
                          child: Transform.rotate(
                            angle: roadBankAngle,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Bayangan kontak ban realistis di atas aspal jalan
                                Positioned(
                                  bottom: scooterHeight * 0.02,
                                  left: scooterWidth * 0.08,
                                  right: scooterWidth * 0.12,
                                  child: Container(
                                    height: 26,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF1A0F0A)
                                              .withValues(alpha: 0.62),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Kepulan asap knalpot halus di belakang bawah motor saat melaju ke depan-atas
                                Positioned(
                                  bottom: scooterHeight * 0.06,
                                  left: scooterWidth * 0.18,
                                  child: CustomPaint(
                                    size: const Size(60, 50),
                                    painter: _RearExhaustSmokePainter(
                                      phase: _engineVibrationController.value,
                                    ),
                                  ),
                                ),

                                // Gambar 3D Kurir & Motor Skuter Oranye Tampak Belakang
                                scooterChild!,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                child: Image.asset(
                  'assets/images/scooter_rider_3d.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              );
            },
          ),

          // 4. LOGO 3D TAS BELANJA ORANYE DI ATAS & TOMBOL SLIDER "COMMENCER" DI BAWAH (Persis Video 2 detik 00:00-00:02)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.80, end: 1.0),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF7844),
                                Color(0xFFE84118),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66F05A28),
                                blurRadius: 22,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_rounded,
                                size: 42,
                                color: Colors.white,
                              ),
                              Positioned(
                                bottom: 14,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.sentiment_satisfied_alt_rounded,
                                    size: 12,
                                    color: AppColors.posOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'CloudPOS',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE84118),
                            letterSpacing: -0.8,
                            shadows: [
                              Shadow(
                                color: Color(0xDDFFFFFF),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Tombol Kapsul Frosted-Glass "Commencer" yang Melebar Jadi "✓✓" (Persis Video 2 detik 00:01)
                  GestureDetector(
                    onTap: _triggerLaunchTransition,
                    child: Container(
                      height: 62,
                      width: double.infinity,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.55),
                          width: 1.4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Center(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity: _isExpandingButton ? 0.0 : 1.0,
                                  child: const Text(
                                    'Commencer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeInOutCubic,
                                width: _isExpandingButton
                                    ? constraints.maxWidth
                                    : 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B35),
                                      Color(0xFFF05A28),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x77F05A28),
                                      blurRadius: 14,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: _isExpandingButton
                                    ? Alignment.centerRight
                                    : Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  child: _showDoubleCheck
                                      ? const Icon(
                                          Icons.done_all_rounded,
                                          key: ValueKey('done_all'),
                                          color: Colors.white,
                                          size: 24,
                                        )
                                      : const Icon(
                                          Icons.arrow_forward_rounded,
                                          key: ValueKey('arrow'),
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay atmosfer Golden Hour, aliran marka jalan perspektif dari depan-atas ke bawah,
/// dan siluet pejalan kaki di trotoar kejauhan yang bergerak halus.
class _GoldenHourRoadMotionOverlayPainter extends CustomPainter {
  final double driveProgress;
  final double cyclePhase;
  final double boostProgress;

  _GoldenHourRoadMotionOverlayPainter({
    required this.driveProgress,
    required this.cyclePhase,
    required this.boostProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Sinar matahari keemasan hangat dari sela gedung kiri
    final sunRayPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFFFBEB).withValues(alpha: 0.18),
          const Color(0xFFFDE047).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, h * 0.25, w, h * 0.55));
    final rayPath = Path()
      ..moveTo(0, h * 0.28)
      ..lineTo(w * 0.95, h * 0.52)
      ..lineTo(w * 0.75, h * 0.78)
      ..lineTo(0, h * 0.52)
      ..close();
    canvas.drawPath(rayPath, sunRayPaint);

    // 2. Garis aliran kecepatan halus di atas aspal (mengalir dari titik hilang depan-atas ke arah kamera)
    //    sehingga jalan raya terasa bergerak saat motor melaju ke DEPAN-ATAS!
    final vanishPt = Offset(w * 0.58, h * 0.56);
    final roadStartPt = Offset(w * 0.06, h * 0.72);
    final dashPaint = Paint()
      ..color = const Color(0xFFFFF7ED).withValues(alpha: 0.34)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final rawT = ((i / 4.0) + cyclePhase) % 1.0;
      final t1 = rawT * rawT;
      final t2 = math.min(1.0, (rawT + 0.12) * (rawT + 0.12));
      final p1 = Offset.lerp(vanishPt, roadStartPt, t1)!;
      final p2 = Offset.lerp(vanishPt, roadStartPt, t2)!;
      dashPaint.strokeWidth = 1.2 + 3.2 * t1;
      canvas.drawLine(p1, p2, dashPaint);
    }

    // 3. Partikel cahaya keemasan (Golden Hour Dust Motes) melayang di udara
    final motePaint = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.42);
    for (int i = 0; i < 7; i++) {
      final px = w * (0.20 + ((i * 0.11 + driveProgress * 0.08) % 0.65));
      final py = h * (0.36 + ((i * 0.07 - cyclePhase * 0.04) % 0.38));
      canvas.drawCircle(Offset(px, py), 1.6 + (i % 2) * 1.0, motePaint);
    }

    // 4. Gradasi bawah lembut agar tombol "Commencer" tampil mewah & kontras
    final bottomGradient = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF1E110A).withValues(alpha: 0.48),
        ],
        stops: const [0.76, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bottomGradient);
  }

  @override
  bool shouldRepaint(
    covariant _GoldenHourRoadMotionOverlayPainter oldDelegate,
  ) {
    return oldDelegate.driveProgress != driveProgress ||
        oldDelegate.cyclePhase != cyclePhase ||
        oldDelegate.boostProgress != boostProgress;
  }
}

/// Kepulan asap knalpot lembut di belakang bawah motor skuter saat melaju ke depan-atas
class _RearExhaustSmokePainter extends CustomPainter {
  final double phase;

  _RearExhaustSmokePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final t = ((phase + i / 3.0) % 1.0);
      final alpha = (1.0 - t) * 0.38;
      final radius = 5.0 + t * 12.0;
      final dx = size.width * 0.75 - (t * 24.0);
      final dy = size.height * 0.25 + (t * 18.0);
      canvas.drawCircle(
        Offset(dx, dy),
        radius,
        Paint()..color = const Color(0xFFFFF7ED).withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RearExhaustSmokePainter oldDelegate) =>
      oldDelegate.phase != phase;
}
