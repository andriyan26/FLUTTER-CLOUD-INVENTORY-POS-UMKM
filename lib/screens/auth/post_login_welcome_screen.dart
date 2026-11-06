import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/cloud_pos_brand_logo.dart';

/// Layar Transisi Animasi Setelah Login Persis VIDEO 2 (KONSEP SETELAH LOGIN.mp4 detik 00:00 - 00:02)
/// Menggunakan Kamera Chase-Cam 3D Realistis 60fps (Unidirectional Forward Motion — Tidak Pernah Mundur):
/// 1) Jalan raya boulevard Golden Hour (`assets/images/boulevard_clean.jpg`) bergerak maju terus-menerus
///    (continuous 3D perspective dolly-in dari titik hilang `Alignment(0.02, 0.04)`) sehingga gedung di kiri,
///    pohon palem & pejalan kaki di trotoar kanan, serta aspal jalan mengalir melewati kamera persis seperti di video!
/// 2) Bayangan pepohonan & cahaya matahari di atas permukaan aspal mengalir turun secara perspektif 3D (`1/z`)
///    melewati bawah roda motor sehingga jalanan terlihat benar-benar berjalan secara nyata.
/// 3) Kurir motor skuter oranye (`assets/images/scooter_rider_3d.png`) sejajar presisi dengan lajur jalan raya,
///    melaju mulus ke depan dengan suspensi 60fps, bayangan aspal jatuh ke arah kanan (sesuai arah matahari),
///    dan berakselerasi maju saat tombol "Commencer" melebar menjadi tanda centang ganda (✓✓).
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
  late final AnimationController _forwardRoadController;
  late final AnimationController _wheelAndSuspensionController;
  late final AnimationController _boostForwardController;
  Timer? _autoLaunchTimer;

  bool _isExpandingButton = false;
  bool _showDoubleCheck = false;

  @override
  void initState() {
    super.initState();

    // Pergerakan maju jalan raya SATU ARAH (Unidirectional Forward — TIDAK PERNAH MUNDUR!)
    _forwardRoadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    // Putaran roda, getaran halus suspensi mesin & aliran bayangan aspal 60fps
    _wheelAndSuspensionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Akselerasi maju ketika tombol "Commencer" ditekan
    _boostForwardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );

    // Transisi otomatis halus seperti di KONSEP SETELAH LOGIN.mp4
    _autoLaunchTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted && !_isExpandingButton) {
        _triggerLaunchTransition();
      }
    });
  }

  @override
  void dispose() {
    _autoLaunchTimer?.cancel();
    _forwardRoadController.dispose();
    _wheelAndSuspensionController.dispose();
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

    await Future.delayed(const Duration(milliseconds: 340));
    if (!mounted) return;
    setState(() {
      _showDoubleCheck = true;
    });
    await Future.delayed(const Duration(milliseconds: 480));
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
          // ===================================================================
          // 1. LAYER JALAN RAYA BOULEVARD DENGAN INFINITE FORWARD DOLLY-IN 3D
          //    Menggunakan 2 layer cross-dissolve yang selalu bergerak MAJU dari
          //    titik hilang jalan raya `Alignment(0.02, 0.04)` (00:00 -> 00:01 Video 2)
          //    sehingga jalanan, gedung, dan pohon palem TERUS BERJALAN MAJU!
          // ===================================================================
          AnimatedBuilder(
            animation: Listenable.merge([
              _forwardRoadController,
              _boostForwardController,
            ]),
            builder: (context, _) {
              final p1 = _forwardRoadController.value;
              final p2 = (p1 + 0.5) % 1.0;
              final boost = Curves.easeInCubic.transform(
                _boostForwardController.value,
              );

              // Skala kamera dolly-in maju dari titik hilang jalan raya
              final scale1 = 1.00 + (p1 * 0.42) + (boost * 0.22);
              final scale2 = 1.00 + (p2 * 0.42) + (boost * 0.22);

              // Opacity cross-fade mulus agar aliran maju jalan raya tak terbatas tanpa pernah mundur
              final alpha2 = math.sin(p1 * math.pi).clamp(0.0, 1.0);

              return Stack(
                fit: StackFit.expand,
                children: [
                  Transform.scale(
                    scale: scale1,
                    alignment: const Alignment(0.02, 0.04),
                    child: Image.asset(
                      'assets/images/boulevard_clean.jpg',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                  Opacity(
                    opacity: alpha2,
                    child: Transform.scale(
                      scale: scale2,
                      alignment: const Alignment(0.02, 0.04),
                      child: Image.asset(
                        'assets/images/boulevard_clean.jpg',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ===================================================================
          // 2. LAYER ALIRAN BAYANGAN POHON & TEKSTUR ASPAL 3D PERSPEKTIF (60FPS)
          //    Membuat permukaan jalan aspal di bawah roda motor benar-benar
          //    mengalir dari depan ke belakang secara realistis!
          // ===================================================================
          AnimatedBuilder(
            animation: Listenable.merge([
              _forwardRoadController,
              _wheelAndSuspensionController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _RealisticPerspectiveRoadSurfacePainter(
                  roadPhase: _forwardRoadController.value,
                  fastPhase: _wheelAndSuspensionController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // ===================================================================
          // 3. LAYER KURIR & MOTOR SKUTER ORANYE 3D (CHASE-CAM MENGIKUTI LAJUR)
          //    Posisi & arah motor sejajar presisi dengan perspektif lajur jalan
          //    di Video 2 (00:00 - 00:01) dengan bayangan matahari jatuh ke kanan!
          // ===================================================================
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return AnimatedBuilder(
                animation: Listenable.merge([
                  _forwardRoadController,
                  _wheelAndSuspensionController,
                  _boostForwardController,
                ]),
                builder: (context, scooterImage) {
                  final wheelPhase = _wheelAndSuspensionController.value;
                  final roadPhase = _forwardRoadController.value;
                  final boostT = Curves.easeInCubic.transform(
                    _boostForwardController.value,
                  );

                  // Goyangan mikro chase-cam yang sangat natural di dalam lajur kiri
                  final laneWeaveX =
                      math.sin(roadPhase * math.pi * 2) * (w * 0.012);
                  final chaseProgressY =
                      math.sin(roadPhase * math.pi) * (h * 0.018);

                  // Saat tombol Commencer ditekan, motor melesat lurus ke titik hilang jalan (x=48%, y=52%)
                  final boostMoveX = boostT * (w * 0.14);
                  final boostMoveUpY = boostT * (h * 0.17);

                  // Getaran halus suspensi mesin 60fps di atas aspal
                  final suspensionBounceY =
                      math.sin(wheelPhase * math.pi * 4) * 1.4;

                  // Kemiringan halus mengikuti lajur jalan (sedikit menghadap ke titik hilang tengah-kiri)
                  final steeringAngle = -0.042 +
                      (math.sin(roadPhase * math.pi * 2) * 0.010) -
                      (boostT * 0.015);

                  // Skala perspektif saat melaju
                  final scooterScale =
                      (1.00 - ( math.sin(roadPhase * math.pi) * 0.04)) *
                          (1.0 - (boostT * 0.34));

                  // Efek cahaya & bayangan pohon yang melewati tubuh pengendara saat melaju
                  final dappledLight =
                      0.5 + 0.5 * math.sin(wheelPhase * math.pi * 2);

                  final scooterWidth = w * 0.45;
                  final scooterHeight = scooterWidth * (550.0 / 315.0);

                  final leftPos = w * 0.035 + laneWeaveX + boostMoveX;
                  final bottomPos = h * 0.145 +
                      chaseProgressY +
                      boostMoveUpY +
                      suspensionBounceY;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        left: leftPos,
                        bottom: bottomPos,
                        width: scooterWidth,
                        height: scooterHeight,
                        child: Transform.scale(
                          scale: scooterScale,
                          alignment: Alignment.bottomCenter,
                          child: Transform.rotate(
                            angle: steeringAngle,
                            alignment: Alignment.bottomCenter,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.bottomCenter,
                              children: [
                                // A. Bayangan panjang sinar matahari Golden Hour jatuh ke kanan aspal
                                //    + bayangan kontak ban hitam pekat tepat di bawah roda
                                Positioned(
                                  bottom: scooterHeight * 0.01,
                                  left: scooterWidth * 0.12,
                                  child: CustomPaint(
                                    size: Size(
                                      scooterWidth * 1.15,
                                      scooterHeight * 0.22,
                                    ),
                                    painter: _RealisticScooterAsphaltShadowPainter(
                                      wheelPhase: wheelPhase,
                                    ),
                                  ),
                                ),

                                // B. Gambar 3D Kurir & Motor Skuter dengan modulasi cahaya matahari jalan raya
                                ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    const Color(0xFFFFE4B5).withValues(
                                      alpha: 0.04 + (dappledLight * 0.06),
                                    ),
                                    BlendMode.srcATop,
                                  ),
                                  child: scooterImage,
                                ),
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

          // ===================================================================
          // 4. LOGO 3D TAS BELANJA ORANYE DI ATAS & TOMBOL SLIDER "COMMENCER"
          //    (Persis Video 2 detik 00:00 - 00:02)
          // ===================================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: const Column(
                      children: [
                        CloudPosEmblemIcon(
                          size: 76,
                          animate: true,
                          showCrownBadge: true,
                        ),
                        SizedBox(height: 8),
                        Text(
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

/// Painter Permukaan Jalan Aspal Perspektif 3D:
/// Mengalirkan pita bayangan pepohonan & berkas sinar matahari keemasan di atas permukaan aspal
/// dari titik hilang `(0.50*w, 0.53*h)` menuju bawah layar dengan kecepatan perspektif `1/z`
/// sehingga aspal jalan raya benar-benar terasa bergerak cepat di bawah roda skuter!
class _RealisticPerspectiveRoadSurfacePainter extends CustomPainter {
  final double roadPhase;
  final double fastPhase;

  _RealisticPerspectiveRoadSurfacePainter({
    required this.roadPhase,
    required this.fastPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Trapesium area permukaan jalan aspal sesuai perspektif boulevard_clean.jpg
    final roadPolygon = Path()
      ..moveTo(w * 0.43, h * 0.53)
      ..lineTo(w * 0.56, h * 0.53)
      ..lineTo(w * 0.82, h * 1.0)
      ..lineTo(-w * 0.15, h * 1.0)
      ..close();

    canvas.save();
    canvas.clipPath(roadPolygon);

    final horizonY = h * 0.53;
    final roadHeight = h - horizonY;

    // 1. Pita-pita bayangan pohon palem & gedung di atas aspal yang mengalir turun secara perspektif 3D
    for (int i = 0; i < 6; i++) {
      final rawProgress = ((i / 6.0) + (roadPhase * 2.0)) % 1.0;
      // Fungsi pangkat (pow 2.35) menghasilkan percepatan perspektif 3D nyata (lambat di jauh, cepat di dekat kamera)
      final p = math.pow(rawProgress, 2.35).toDouble();
      final yCenter = horizonY + (roadHeight * p);
      final bandThickness = 4.0 + (38.0 * p);

      // Opacity memudar lembut di kejauhan dan di tepi bawah
      final fade = math.sin(rawProgress * math.pi).clamp(0.0, 1.0);
      final shadowAlpha = (0.16 * fade).clamp(0.0, 0.22);

      final shadowPath = Path()
        ..moveTo(-w * 0.1, yCenter - bandThickness * 0.35)
        ..lineTo(w * 0.85, yCenter + bandThickness * 0.25)
        ..lineTo(w * 0.85, yCenter + bandThickness * 0.85)
        ..lineTo(-w * 0.1, yCenter + bandThickness * 0.25)
        ..close();

      canvas.drawPath(
        shadowPath,
        Paint()
          ..color = const Color(0xFF1A0E08).withValues(alpha: shadowAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0),
      );
    }

    // 2. Aliran mikro tekstur aspal hangat searah lajur ban motor (halus & realistis, BUKAN garis putih!)
    final vanishPt = Offset(w * 0.49, horizonY);
    for (int i = 0; i < 5; i++) {
      final laneOffset = (i - 2) * 0.14;
      final bottomPt = Offset(w * (0.28 + laneOffset), h);
      final rawT = ((i * 0.2) + fastPhase) % 1.0;
      final t1 = math.pow(rawT, 2.2).toDouble();
      final t2 = math.pow(math.min(1.0, rawT + 0.14), 2.2).toDouble();

      final p1 = Offset.lerp(vanishPt, bottomPt, t1)!;
      final p2 = Offset.lerp(vanishPt, bottomPt, t2)!;

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = const Color(0xFFFFE4B5).withValues(alpha: 0.07 * t1)
          ..strokeWidth = 1.0 + (2.5 * t1)
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
      );
    }

    canvas.restore();

    // 3. Gradasi bawah lembut untuk kontras tombol Commencer
    final bottomVignette = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF1A0F0A).withValues(alpha: 0.45),
        ],
        stops: const [0.78, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bottomVignette);
  }

  @override
  bool shouldRepaint(
    covariant _RealisticPerspectiveRoadSurfacePainter oldDelegate,
  ) =>
      oldDelegate.roadPhase != roadPhase || oldDelegate.fastPhase != fastPhase;
}

/// Painter Bayangan Motor Skuter di Atas Aspal:
/// - Bayangan kontak hitam pekat tepat di bawah ban belakang & ban depan
/// - Bayangan panjang lembut jatuh menyerong ke kanan-bawah sesuai arah sinar matahari Golden Hour di Video 2!
class _RealisticScooterAsphaltShadowPainter extends CustomPainter {
  final double wheelPhase;

  _RealisticScooterAsphaltShadowPainter({required this.wheelPhase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Bayangan jatuh memanjang ke kanan aspal (Cast Shadow dari matahari kiri)
    final castShadowPath = Path()
      ..moveTo(w * 0.18, h * 0.72)
      ..quadraticBezierTo(w * 0.55, h * 0.52, w * 0.92, h * 0.68)
      ..quadraticBezierTo(w * 0.62, h * 0.95, w * 0.16, h * 0.88)
      ..close();

    canvas.drawPath(
      castShadowPath,
      Paint()
        ..color = const Color(0xFF140B06).withValues(alpha: 0.48)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0),
    );

    // 2. Bayangan kontak ban belakang & depan tepat menempel di aspal
    final tireContactRect = Rect.fromCenter(
      center: Offset(w * 0.30, h * 0.78),
      width: w * 0.38,
      height: h * 0.26,
    );
    canvas.drawOval(
      tireContactRect,
      Paint()
        ..color = const Color(0xFF090503).withValues(alpha: 0.82)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
    );
  }

  @override
  bool shouldRepaint(
    covariant _RealisticScooterAsphaltShadowPainter oldDelegate,
  ) =>
      oldDelegate.wheelPhase != wheelPhase;
}
