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
  late final AnimationController _timelineController;
  late final AnimationController _engineLoopController;

  late final Animation<Offset> _scooterPosition;
  late final Animation<double> _scooterLean;
  late final Animation<double> _circleScale;
  late final Animation<double> _circleOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // Total durasi 2950ms mencakup:
    // 1) Masuk dari kiri ke tengah (0.00 - 0.40)
    // 2) Idle bertenaga di tengah (0.40 - 0.66)
    // 3) Tancap gas bergerak keluar ke KANAN penuh sebelum Form Login muncul (0.66 - 0.98)
    _timelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2950),
    );

    _engineLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..repeat();

    _scooterPosition = TweenSequence<Offset>([
      // Fase 1: Masuk dari kiri ke tengah
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-1.85, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      // Fase 2: Berhenti sejenak di tengah
      TweenSequenceItem(
        tween: ConstantTween<Offset>(Offset.zero),
        weight: 26,
      ),
      // Fase 3: Bergerak melaju kencang ke KANAN keluar layar (Persis KONSEP LOGIN.mp4 detik 00:04-00:05)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(2.25, 0.0),
        ).chain(CurveTween(curve: Curves.easeInBack)),
        weight: 34,
      ),
    ]).animate(_timelineController);

    _scooterLean = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 26,
      ),
      // Sedikit angkat roda depan / condong saat tancap gas ke kanan
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.08)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 34,
      ),
    ]).animate(_timelineController);

    _circleScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 36,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 34,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.75)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 30,
      ),
    ]).animate(_timelineController);

    _circleOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 47,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 28,
      ),
    ]).animate(_timelineController);

    _textOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 28,
      ),
    ]).animate(_timelineController);

    _textSlide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(0, 0.35)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 0.35),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(Offset.zero),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -0.15),
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 28,
      ),
    ]).animate(_timelineController);

    _timelineController.forward().whenComplete(() {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _engineLoopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ClipRect(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 260,
                height: 215,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    FadeTransition(
                      opacity: _circleOpacity,
                      child: ScaleTransition(
                        scale: _circleScale,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFD9F99D).withValues(alpha: 0.58),
                                const Color(0xFFEAF5E4),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: _scooterPosition,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _engineLoopController,
                          _timelineController,
                        ]),
                        builder: (context, _) {
                          final bounceDy = math.sin(
                                _engineLoopController.value * math.pi * 2,
                              ) *
                              -3.5;
                          return Transform.translate(
                            offset: Offset(0, bounceDy),
                            child: Transform.rotate(
                              angle: _scooterLean.value,
                              child: CloudPosScooterIllustration(
                                size: 170,
                                flipHorizontal: false,
                                wheelPhase: _engineLoopController.value,
                                showSpeedLines:
                                    _timelineController.value < 0.38 ||
                                        _timelineController.value > 0.66,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
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
                              style: TextStyle(
                                color: AppColors.loginPrimaryGreen,
                              ),
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
      ),
    );
  }
}

/// Ilustrasi Vektor Custom-Painted Kurir Skuter Hijau (Persis Karakter di KONSEP LOGIN.mp4)
/// Mendukung arah hadap kanan (`flipHorizontal: false` saat Splash) maupun
/// arah hadap kiri (`flipHorizontal: true` saat masuk dari kanan di Header Form Login).
class CloudPosScooterIllustration extends StatelessWidget {
  final double size;
  final bool flipHorizontal;
  final double wheelPhase;
  final bool showSpeedLines;

  const CloudPosScooterIllustration({
    super.key,
    this.size = 150,
    this.flipHorizontal = false,
    this.wheelPhase = 0.0,
    this.showSpeedLines = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget painterWidget = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ScooterMascotPainter(
          wheelPhase: wheelPhase,
          showSpeedLines: showSpeedLines,
        ),
      ),
    );

    if (flipHorizontal) {
      painterWidget = Transform.flip(
        flipX: true,
        child: painterWidget,
      );
    }

    return painterWidget;
  }
}

class _ScooterMascotPainter extends CustomPainter {
  final double wheelPhase;
  final bool showSpeedLines;

  _ScooterMascotPainter({
    required this.wheelPhase,
    required this.showSpeedLines,
  });

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

    // 2. Garis angin kecepatan & kepulan asap knalpot dinamis di belakang motor
    final puffShift = (wheelPhase * 12.0) % 8.0;
    final puffPaint = Paint()
      ..color = const Color(0xFFBEF264).withValues(alpha: 0.72);
    canvas.drawCircle(
      Offset(w * 0.09 - puffShift, h * 0.72),
      w * 0.055,
      puffPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.16 - puffShift * 0.6, h * 0.75),
      w * 0.042,
      puffPaint,
    );

    if (showSpeedLines) {
      final speedLinePaint = Paint()
        ..color = const Color(0xFF84CC16).withValues(alpha: 0.55)
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(w * 0.0, h * 0.42),
        Offset(w * 0.12, h * 0.42),
        speedLinePaint,
      );
      canvas.drawLine(
        Offset(-w * 0.04, h * 0.58),
        Offset(w * 0.10, h * 0.58),
        speedLinePaint,
      );
    }

    // 3. Roda Belakang & Roda Depan dengan Jari-Jari Berputar
    final tirePaint = Paint()..color = const Color(0xFF1E242B);
    final rimPaint = Paint()..color = const Color(0xFFE2E8F0);
    final hubPaint = Paint()..color = const Color(0xFF4E8D2A);
    final spokePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.8;

    final rearWheelCenter = Offset(w * 0.28, h * 0.76);
    final frontWheelCenter = Offset(w * 0.74, h * 0.76);
    final rotAngle = wheelPhase * math.pi * 2;

    for (final center in [rearWheelCenter, frontWheelCenter]) {
      canvas.drawCircle(center, w * 0.115, tirePaint);
      canvas.drawCircle(center, w * 0.065, rimPaint);
      for (int i = 0; i < 4; i++) {
        final a = rotAngle + (i * math.pi / 2);
        canvas.drawLine(
          center + Offset(math.cos(a) * w * 0.02, math.sin(a) * w * 0.02),
          center + Offset(math.cos(a) * w * 0.06, math.sin(a) * w * 0.06),
          spokePaint,
        );
      }
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
      ..lineTo(w * 0.62, h * 0.43)
      ..lineTo(w * 0.46, h * 0.58)
      ..close();
    canvas.drawPath(torsoPath, torsoPaint);

    // Lengan Kurir memegang stang skuter
    final armPaint = Paint()
      ..color = const Color(0xFF4E8D2A)
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.47, h * 0.38),
      Offset(w * 0.68, h * 0.42),
      armPaint,
    );

    // Wajah & Helm Hijau Cerah
    final facePaint = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawCircle(Offset(w * 0.49, h * 0.23), w * 0.075, facePaint);

    // Kacamata / Mata Kurir
    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(Offset(w * 0.53, h * 0.22), w * 0.013, eyePaint);

    final helmetPaint = Paint()..color = const Color(0xFF65A30D);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.48, h * 0.22), radius: w * 0.088),
      math.pi * 0.92,
      math.pi * 1.18,
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
  bool shouldRepaint(covariant _ScooterMascotPainter oldDelegate) {
    return oldDelegate.wheelPhase != wheelPhase ||
        oldDelegate.showSpeedLines != showSpeedLines;
  }
}
