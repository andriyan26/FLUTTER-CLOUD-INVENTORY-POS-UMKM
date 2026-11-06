import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Layar Transisi Animasi Setelah Login Persis VIDEO 2 (KONSEP SETELAH LOGIN.mp4 detik 00:00 - 00:02)
/// Menampilkan ANIMASI HIDUP 60FPS (Bukan foto diam!):
/// - Kurir mengendarai motor skuter oranye yang sedang berjalan aktif di jalan raya golden-hour
/// - Orang-orang (pejalan kaki) yang sedang berjalan kaki di trotoar kiri & kanan dengan langkah kaki berayun
/// - Logo 3D tas belanja oranye CloudPOS di atas
/// - Tombol kapsul frosted-glass "Commencer" di bawah yang melebar menjadi centang ganda (✓✓)
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
  late final AnimationController _sceneController;
  late final AnimationController _scooterBoostController;
  Timer? _autoLaunchTimer;

  bool _isExpandingButton = false;
  bool _showDoubleCheck = false;

  @override
  void initState() {
    super.initState();

    // Controller utama 60fps untuk animasi motor berjalan, roda berputar, marka jalan & orang berjalan kaki
    _sceneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    // Controller akselerasi motor saat tombol "Commencer" ditekan
    _scooterBoostController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    // Beri waktu 3.8 detik agar pengguna dapat melihat animasi motor & orang berjalan dengan jelas,
    // atau pengguna bisa langsung klik tombol "Commencer" kapan saja.
    _autoLaunchTimer = Timer(const Duration(milliseconds: 3800), () {
      if (mounted && !_isExpandingButton) {
        _triggerLaunchTransition();
      }
    });
  }

  @override
  void dispose() {
    _autoLaunchTimer?.cancel();
    _sceneController.dispose();
    _scooterBoostController.dispose();
    super.dispose();
  }

  Future<void> _triggerLaunchTransition() async {
    if (_isExpandingButton) return;
    _autoLaunchTimer?.cancel();
    setState(() {
      _isExpandingButton = true;
    });
    _scooterBoostController.forward();

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
          // 1. ANIMASI KANVAS 60FPS: JALAN RAYA GOLDEN HOUR, ORANG BERJALAN KAKI & MOTOR SKUTER ORANYE MELAJU
          AnimatedBuilder(
            animation: Listenable.merge([
              _sceneController,
              _scooterBoostController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _GoldenHourStreetAndScooterPainter(
                  phase: _sceneController.value,
                  boostProgress: Curves.easeInCubic.transform(
                    _scooterBoostController.value,
                  ),
                ),
                size: Size.infinite,
              );
            },
          ),

          // 2. LOGO 3D TAS BELANJA ORANYE DI ATAS & TOMBOL SLIDER "COMMENCER" DI BAWAH (Persis Video 2 detik 00:00-00:02)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.78, end: 1.0),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 74,
                          height: 74,
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
                                blurRadius: 24,
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
                                bottom: 15,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.sentiment_satisfied_alt_rounded,
                                    size: 13,
                                    color: AppColors.posOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'CloudPOS',
                          style: TextStyle(
                            fontSize: 31,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE84118),
                            letterSpacing: -0.8,
                            shadows: [
                              Shadow(
                                color: Color(0xCCFFFFFF),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 3. Tombol Kapsul Bawah "Commencer" yang Melebar Jadi "✓✓" (Persis Video 2 detik 00:01)
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
                          color: Colors.white.withValues(alpha: 0.52),
                          width: 1.4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x44000000),
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

/// CustomPainter 60fps yang menggambar suasana jalan raya kota saat Golden Hour
/// lengkap dengan gedung perspektif, pejalan kaki yang sedang berjalan di trotoar,
/// dan kurir motor skuter oranye yang sedang dikendarai aktif.
class _GoldenHourStreetAndScooterPainter extends CustomPainter {
  final double phase;
  final double boostProgress;

  _GoldenHourStreetAndScooterPainter({
    required this.phase,
    required this.boostProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * 0.45;
    final vanishX = w * 0.50;

    // 1. LANGIT GOLDEN HOUR (Biru muda hangat di atas -> Keemasan jingga di cakrawala)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFD8ECF8),
          Color(0xFFFDE68A),
          Color(0xFFFDBA74),
          Color(0xFFF97316),
        ],
        stops: [0.0, 0.48, 0.78, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, horizonY + 40));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, horizonY + 40), skyPaint);

    // Cahaya matahari hangat (Sun Glow) di sisi kiri tengah cakrawala
    final sunGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFBEB).withValues(alpha: 0.92),
          const Color(0xFFFDE047).withValues(alpha: 0.45),
          const Color(0x00F97316),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(w * 0.36, horizonY * 0.85),
          radius: w * 0.52,
        ),
      );
    canvas.drawCircle(
      Offset(w * 0.36, horizonY * 0.85),
      w * 0.52,
      sunGlowPaint,
    );

    // 2. GEDUNG KOTA EROPA / BOULEVARD KIRI & KANAN DENGAN PERSPEKTIF
    final leftBuildingPath = Path()
      ..moveTo(0, horizonY * 0.25)
      ..lineTo(vanishX - w * 0.09, horizonY)
      ..lineTo(vanishX - w * 0.09, horizonY + 12)
      ..lineTo(0, h * 0.62)
      ..close();
    final leftBuildingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9A5B3E), Color(0xFF5C2D16)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w * 0.5, h * 0.65));
    canvas.drawPath(leftBuildingPath, leftBuildingPaint);

    final rightBuildingPath = Path()
      ..moveTo(w, horizonY * 0.18)
      ..lineTo(vanishX + w * 0.09, horizonY)
      ..lineTo(vanishX + w * 0.09, horizonY + 12)
      ..lineTo(w, h * 0.64)
      ..close();
    final rightBuildingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7C3F23), Color(0xFF431E0F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h * 0.65));
    canvas.drawPath(rightBuildingPath, rightBuildingPaint);

    // Jendela & Kanopi Toko yang bergerak mendekat sesuai perspektif jalan
    final windowPaint = Paint()
      ..color = const Color(0xFFFef08a).withValues(alpha: 0.55);
    for (int i = 0; i < 5; i++) {
      final depth = ((i / 5.0) + phase) % 1.0;
      final yTop = horizonY * (0.35 + (1.0 - depth) * 0.55);
      final xLeft = (vanishX - w * 0.10) * (1.0 - depth);
      final xRight = w - (w - (vanishX + w * 0.10)) * (1.0 - depth);
      final winH = 14.0 * depth + 4.0;
      final winW = 8.0 * depth + 2.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(xLeft, yTop),
            width: winW,
            height: winH,
          ),
          const Radius.circular(3),
        ),
        windowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(xRight, yTop),
            width: winW,
            height: winH,
          ),
          const Radius.circular(3),
        ),
        windowPaint,
      );
    }

    // 3. JALAN RAYA ASPAL & TROTOAR KIRI-KANAN (GOLDEN HOUR ROAD)
    final sidewalkPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD97706), Color(0xFF78350F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, w, h - horizonY),
      sidewalkPaint,
    );

    // Badan jalan aspal utama di tengah
    final roadPath = Path()
      ..moveTo(vanishX - w * 0.08, horizonY)
      ..lineTo(vanishX + w * 0.08, horizonY)
      ..lineTo(w * 1.18, h)
      ..lineTo(-w * 0.18, h)
      ..close();
    final roadPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFB45309),
          Color(0xFF6B2F14),
          Color(0xFF2E150B),
        ],
        stops: [0.0, 0.38, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawPath(roadPath, roadPaint);

    // Garis tepi trotoar bercahaya keemasan
    final curbPaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.45)
      ..strokeWidth = 2.2;
    canvas.drawLine(
      Offset(vanishX - w * 0.08, horizonY),
      Offset(-w * 0.12, h),
      curbPaint,
    );
    canvas.drawLine(
      Offset(vanishX + w * 0.08, horizonY),
      Offset(w * 1.12, h),
      curbPaint,
    );

    // 4. MARKA JALAN & ZEBRA CROSS BERGERak MAJU (Memberikan efek motor sedang berjalan kencang!)
    final dashPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.70)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final rawT = ((i / 6.0) + (phase * 2.0)) % 1.0;
      final t = rawT * rawT; // Perspektif kuadratik
      final nextT = math.min(1.0, (rawT + 0.09) * (rawT + 0.09));
      final y1 = horizonY + (h - horizonY) * t;
      final y2 = horizonY + (h - horizonY) * nextT;

      dashPaint.strokeWidth = 2.0 + 6.0 * t;
      // Garis lajur kiri & kanan
      final xLeft1 = vanishX - (w * 0.03) - (w * 0.28 * t);
      final xLeft2 = vanishX - (w * 0.03) - (w * 0.28 * nextT);
      canvas.drawLine(Offset(xLeft1, y1), Offset(xLeft2, y2), dashPaint);

      final xRight1 = vanishX + (w * 0.03) + (w * 0.28 * t);
      final xRight2 = vanishX + (w * 0.03) + (w * 0.28 * nextT);
      canvas.drawLine(Offset(xRight1, y1), Offset(xRight2, y2), dashPaint);
    }

    // 5. ORANG-ORANG YANG SEDANG BERJALAN KAKI DI TROTOAR & SEBERANG JALAN (Persis Video 2!)
    // Kita gambar beberapa pejalan kaki dengan animasi ayunan kaki & tangan (walkCycle)
    final walkCycle = phase * math.pi * 8;

    // Pejalan kaki 1 (Trotoar Kiri Depan - sedang berjalan aktif)
    final ped1Depth = 0.36 + 0.12 * math.sin(phase * math.pi * 2);
    _drawWalkingPedestrian(
      canvas: canvas,
      footPos: Offset(w * 0.17, horizonY + (h - horizonY) * ped1Depth),
      scale: 0.85,
      stridePhase: walkCycle,
      coatColor: const Color(0xFF1E293B),
      pantsColor: const Color(0xFF334155),
      facingRight: true,
      hasBag: true,
    );

    // Pejalan kaki 2 (Trotoar Kiri Kejauhan)
    _drawWalkingPedestrian(
      canvas: canvas,
      footPos: Offset(w * 0.29, horizonY + (h - horizonY) * 0.18),
      scale: 0.56,
      stridePhase: walkCycle + 1.8,
      coatColor: const Color(0xFF7C2D12),
      pantsColor: const Color(0xFF1E293B),
      facingRight: false,
      hasBag: false,
    );

    // Pejalan kaki 3 (Trotoar Kanan Depan - sedang berjalan membawa tas belanja)
    final ped3Depth = 0.42 - 0.10 * math.cos(phase * math.pi * 2);
    _drawWalkingPedestrian(
      canvas: canvas,
      footPos: Offset(w * 0.84, horizonY + (h - horizonY) * ped3Depth),
      scale: 0.92,
      stridePhase: walkCycle + 0.9,
      coatColor: const Color(0xFF9A3412),
      pantsColor: const Color(0xFF0F172A),
      facingRight: false,
      hasBag: true,
    );

    // Pejalan kaki 4 (Trotoar Kanan Tengah)
    _drawWalkingPedestrian(
      canvas: canvas,
      footPos: Offset(w * 0.73, horizonY + (h - horizonY) * 0.23),
      scale: 0.62,
      stridePhase: walkCycle + 2.7,
      coatColor: const Color(0xFF334155),
      pantsColor: const Color(0xFF1E293B),
      facingRight: true,
      hasBag: false,
    );

    // Pengendara skuter kedua di kejauhan tengah jalan
    _drawDistantRider(
      canvas: canvas,
      pos: Offset(
        vanishX - w * 0.05 + math.sin(phase * math.pi * 2) * 8,
        horizonY + (h - horizonY) * 0.19,
      ),
      scale: 0.48,
    );

    // 6. KURIR UTAMA DENGAN MOTOR SKUTER ORANYE SEDANG BERJALAN DI TENGAH JALAN (FOREGROUND HERO)
    final swayX = math.sin(phase * math.pi * 2) * (w * 0.032) +
        (boostProgress * w * 0.25);
    final bounceY = math.sin(phase * math.pi * 6) * 3.8 -
        (boostProgress * h * 0.06);
    final scooterCenter = Offset(w * 0.48 + swayX, h * 0.69 + bounceY);

    _drawForegroundOrangeScooterRider(
      canvas: canvas,
      center: scooterCenter,
      width: math.min(w * 0.68, 270.0),
      wheelAngle: phase * math.pi * 12,
      tiltAngle: math.sin(phase * math.pi * 2) * 0.035,
    );

    // 7. VIGNETTE BAWAH HANGAT AGAR TOMBOL "COMMENCER" KONTRAS & ELEGAN
    final bottomVignette = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF1C0D06).withValues(alpha: 0.65),
          const Color(0xFF140904).withValues(alpha: 0.88),
        ],
        stops: const [0.55, 0.82, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bottomVignette);
  }

  /// Menggambar pejalan kaki dengan kaki dan lengan yang mengayun (benar-benar terlihat berjalan)
  void _drawWalkingPedestrian({
    required Canvas canvas,
    required Offset footPos,
    required double scale,
    required double stridePhase,
    required Color coatColor,
    required Color pantsColor,
    required bool facingRight,
    required bool hasBag,
  }) {
    canvas.save();
    canvas.translate(footPos.dx, footPos.dy);
    if (!facingRight) {
      canvas.scale(-scale, scale);
    } else {
      canvas.scale(scale, scale);
    }

    final legSwing = math.sin(stridePhase) * 10.0;
    final armSwing = -math.sin(stridePhase) * 9.0;
    final bobY = math.abs(math.cos(stridePhase)) * -2.5;

    // Bayangan panjang golden-hour di trotoar
    final shadowPaint = Paint()
      ..color = const Color(0xFF271105).withValues(alpha: 0.42);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 32, height: 8),
      shadowPaint,
    );

    final legPaint = Paint()
      ..color = pantsColor
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    // Kaki kiri & kaki kanan melangkah bergantian
    canvas.drawLine(
      Offset(-2, -24 + bobY),
      Offset(-4 - legSwing, 0),
      legPaint,
    );
    canvas.drawLine(
      Offset(2, -24 + bobY),
      Offset(4 + legSwing, 0),
      legPaint,
    );

    // Badan / Jaket
    final bodyPaint = Paint()..color = coatColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -37 + bobY),
          width: 16,
          height: 26,
        ),
        const Radius.circular(7),
      ),
      bodyPaint,
    );

    // Kepala dengan cahaya rim golden-hour
    final headPaint = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawCircle(Offset(1, -56 + bobY), 7.5, headPaint);
    final hairPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, -57 + bobY), radius: 7.8),
      math.pi * 0.85,
      math.pi * 1.25,
      true,
      hairPaint,
    );

    // Lengan mengayun saat berjalan
    final armPaint = Paint()
      ..color = coatColor
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round;
    final handEnd = Offset(5 + armSwing, -26 + bobY);
    canvas.drawLine(Offset(0, -45 + bobY), handEnd, armPaint);

    // Tas belanja oranye jika membawa tas
    if (hasBag) {
      final bagPaint = Paint()..color = const Color(0xFFF05A28);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: handEnd + const Offset(0, 8),
            width: 11,
            height: 12,
          ),
          const Radius.circular(3),
        ),
        bagPaint,
      );
    }

    canvas.restore();
  }

  /// Menggambar pengendara di kejauhan jalan
  void _drawDistantRider({
    required Canvas canvas,
    required Offset pos,
    required double scale,
  }) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale, scale);

    final shadowPaint = Paint()
      ..color = const Color(0xFF1C0A00).withValues(alpha: 0.45);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 18), width: 28, height: 8),
      shadowPaint,
    );

    final bikePaint = Paint()..color = const Color(0xFFEA580C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 4), width: 16, height: 22),
        const Radius.circular(6),
      ),
      bikePaint,
    );
    final riderPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(const Offset(0, -14), 8, riderPaint);
    final helmetPaint = Paint()..color = const Color(0xFFF97316);
    canvas.drawCircle(const Offset(0, -24), 6.5, helmetPaint);

    canvas.restore();
  }

  /// Menggambar Kurir dengan Motor Skuter Oranye yang sedang dikendarai di jalan (Persis Video 2 detik 00:00 - 00:02)
  void _drawForegroundOrangeScooterRider({
    required Canvas canvas,
    required Offset center,
    required double width,
    required double wheelAngle,
    required double tiltAngle,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tiltAngle);

    final s = width / 240.0;
    canvas.scale(s, s);

    // 1. Sorot Lampu Depan Keemasan di Aspal & Bayangan Motor
    final headlightBeam = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFef08a).withValues(alpha: 0.45),
          const Color(0x00F97316),
        ],
      ).createShader(
        Rect.fromCircle(center: const Offset(55, 68), radius: 95),
      );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 74), width: 165, height: 40),
      headlightBeam,
    );

    final shadowPaint = Paint()
      ..color = const Color(0xFF140702).withValues(alpha: 0.65);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-6, 70), width: 176, height: 26),
      shadowPaint,
    );

    // 2. Kepulan Asap Knalpot Dinamis di Kiri Belakang Motor
    final puffOffset = (wheelAngle * 4.5) % 18.0;
    final puffPaint = Paint()
      ..color = const Color(0xFFFFEDD5).withValues(alpha: 0.52);
    canvas.drawCircle(Offset(-95 - puffOffset, 42), 11, puffPaint);
    canvas.drawCircle(Offset(-112 - puffOffset * 1.2, 36), 15, puffPaint);
    canvas.drawCircle(Offset(-82 - puffOffset * 0.5, 48), 8, puffPaint);

    // 3. Roda Belakang & Roda Depan Berputar Aktif
    final tirePaint = Paint()..color = const Color(0xFF18181B);
    final rimPaint = Paint()..color = const Color(0xFFE2E8F0);
    final spokePaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 2.6;
    final hubPaint = Paint()..color = const Color(0xFFF05A28);

    for (final wheelPos in [const Offset(-54, 48), const Offset(54, 48)]) {
      canvas.drawCircle(wheelPos, 26, tirePaint);
      canvas.drawCircle(wheelPos, 15, rimPaint);
      for (int i = 0; i < 4; i++) {
        final a = wheelAngle + (i * math.pi / 2);
        canvas.drawLine(
          wheelPos + Offset(math.cos(a) * 4, math.sin(a) * 4),
          wheelPos + Offset(math.cos(a) * 14, math.sin(a) * 14),
          spokePaint,
        );
      }
      canvas.drawCircle(wheelPos, 6, hubPaint);
    }

    // 4. Boks Pengiriman Oranye CloudPOS di Belakang Jok
    final boxPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7844), Color(0xFFD9380F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-86, -42, 52, 48));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-86, -42, 52, 48),
        const Radius.circular(10),
      ),
      boxPaint,
    );
    // Strip putih reflektif pada boks kurir
    canvas.drawRect(
      const Rect.fromLTWH(-86, -20, 52, 7),
      Paint()..color = const Color(0xFFFFF7ED),
    );

    // 5. Tubuh Pengendara Kurir (Jaket Gelap Hangat, Celana, Sepatu & Helm Oranye/Gelap)
    // Kaki pengendara di dek skuter
    final legPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final legPath = Path()
      ..moveTo(-18, -2)
      ..lineTo(12, 12)
      ..lineTo(10, 42);
    canvas.drawPath(legPath, legPaint);

    // Jaket Kurir
    final jacketPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF334155), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-38, -68, 56, 66));
    final torsoPath = Path()
      ..moveTo(-34, 0)
      ..quadraticBezierTo(-36, -54, -8, -64)
      ..lineTo(14, -52)
      ..lineTo(4, 2)
      ..close();
    canvas.drawPath(torsoPath, jacketPaint);

    // Lengan Kurir memegang stang depan
    final armPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-2, -48), const Offset(36, -24), armPaint);

    // Kepala & Helm Kurir dengan Visor
    canvas.drawCircle(
      const Offset(2, -80),
      15,
      Paint()..color = const Color(0xFFFDE68A),
    );
    final helmetPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7844), Color(0xFFEA580C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: const Offset(0, -82), radius: 18));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -82), radius: 18),
      math.pi * 0.88,
      math.pi * 1.25,
      true,
      helmetPaint,
    );
    // Kaca Visor Helm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, -86, 12, 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );

    // 6. Bodi Skuter Vespa Oranye Glossy (Persis Skuter Oranye di Video 2!)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF8552),
          Color(0xFFF05A28),
          Color(0xFFC2410C),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-76, -34, 152, 82));

    final scooterBody = Path()
      ..moveTo(-74, 38)
      ..quadraticBezierTo(-68, 2, -22, 2)
      ..lineTo(20, 34)
      ..lineTo(38, -26)
      ..lineTo(50, -24)
      ..quadraticBezierTo(68, 6, 56, 42)
      ..lineTo(-74, 42)
      ..close();
    canvas.drawPath(scooterBody, bodyPaint);

    // Spakbor roda depan oranye
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(54, 46), radius: 30),
      math.pi * 1.05,
      math.pi * 0.85,
      true,
      bodyPaint,
    );

    // Jok motor hitam ergonomis
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-38, -6, 44, 13),
        const Radius.circular(7),
      ),
      Paint()..color = const Color(0xFF18181B),
    );

    // Lampu Depan Bulat Bersinar Kuning Hangat
    canvas.drawCircle(
      const Offset(49, -24),
      8.5,
      Paint()..color = const Color(0xFFFEF08A),
    );
    canvas.drawCircle(
      const Offset(49, -24),
      13,
      Paint()..color = const Color(0x55FEF08A),
    );

    // Lampu Rem Merah di Belakang
    canvas.drawCircle(
      const Offset(-75, 22),
      5.5,
      Paint()..color = const Color(0xFFEF4444),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoldenHourStreetAndScooterPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.boostProgress != boostProgress;
  }
}
