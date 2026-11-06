import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Dialog Animasi Pelacakan Pengiriman Kurir Motor & Pejalan Kaki (Persis KONSEP SETELAH LOGIN.mp4 detik 00:16 - 00:20)
/// Menampilkan:
/// 1) Tab "Status Pesanan" (Votre commande est en préparation + ilustrasi kurir motor & tombol Suivre ma livraison)
/// 2) Tab "Live Peta Kurir" (Peta interaktif dengan rute oranye, motor skuter oranye bergerak real-time, badge "3 min",
///    orang berjalan di sekitar titik tujuan, dan kartu kurir "Yacine B. • Votre livreur • Scooter")
class LiveDeliveryTrackerDialog extends StatefulWidget {
  final String transactionCode;
  final String customerName;

  const LiveDeliveryTrackerDialog({
    super.key,
    this.transactionCode = 'INV-20261106-001',
    this.customerName = 'Pelanggan UMKM',
  });

  @override
  State<LiveDeliveryTrackerDialog> createState() =>
      _LiveDeliveryTrackerDialogState();
}

class _LiveDeliveryTrackerDialogState extends State<LiveDeliveryTrackerDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  bool _showLiveMap = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 700),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF6F0),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER SWITCHER (Persis Video 2 detik 00:17 - 00:20)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.posOrangeLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.delivery_dining_rounded,
                                color: AppColors.posOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Suivre ma livraison • Kurir Live',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDarkSlate,
                                  ),
                                ),
                                Text(
                                  '${widget.transactionCode} • ${widget.customerName}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _showLiveMap = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: !_showLiveMap
                                      ? AppColors.posOrange
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'En Préparation (00:17)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: !_showLiveMap
                                        ? Colors.white
                                        : AppColors.textDarkSlate,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _showLiveMap = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: _showLiveMap
                                      ? AppColors.posOrange
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Live Map Scooter (00:19)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: _showLiveMap
                                        ? Colors.white
                                        : AppColors.textDarkSlate,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ISI KONTEN UTAMA
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: _showLiveMap
                      ? _buildLiveMapSection()
                      : _buildOrderPreparationSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tampilan Persis Video 2 detik 00:16 - 00:17 ("Votre commande est en préparation")
  Widget _buildOrderPreparationSection() {
    return Padding(
      key: const ValueKey('prep_view'),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Votre commande\nest en préparation',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppColors.textDarkSlate,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous serez livrés dans quelques instants !\nKurir skuter sedang menuju lokasi pelanggan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  final t = math.sin(_animController.value * math.pi);
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.scale(
                        scale: 1.0 + t * 0.06,
                        child: Image.asset(
                          'assets/images/boulevard_clean.jpg',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, 0.35),
                        ),
                      ),
                      Positioned(
                        left: 36 + t * 28,
                        bottom: 8 + t * 22,
                        width: 118,
                        height: 175,
                        child: Transform.scale(
                          scale: 1.0 - t * 0.16,
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/images/scooter_rider_3d.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => setState(() => _showLiveMap = true),
            child: Container(
              height: 54,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3ECE4),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.posOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Suivre ma livraison',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilan Persis Video 2 detik 00:18 - 00:20 (Peta Rute Pengiriman + Motor Skuter Oranye Bergerak + "3 min" + Yacine B.)
  Widget _buildLiveMapSection() {
    return SizedBox(
      key: const ValueKey('map_view'),
      height: 440,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Kanvas Peta Rute & Motor Skuter Oranye Bergerak
          AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return CustomPaint(
                painter: _LiveDeliveryMapPainter(
                  phase: _animController.value,
                ),
              );
            },
          ),

          // Kartu Kurir di Bawah Peta (Persis Video 2 detik 00:19: "Yacine B. • Votre livreur • Scooter")
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x220F172A),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7844), Color(0xFFF05A28)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.posOrangeLight,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.sports_motorsports_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Yacine B.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDarkSlate,
                          ),
                        ),
                        Text(
                          'Votre livreur • Scooter CloudPOS',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.posOrange,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.loginPrimaryGreen,
                            content: Text(
                              'Menghubungi kurir Yacine B. (Scooter CloudPOS)...',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: Colors.white,
                        size: 19,
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

class _LiveDeliveryMapPainter extends CustomPainter {
  final double phase;

  _LiveDeliveryMapPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background Peta Krem Hangat (Persis Video 2 detik 00:19)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFF3ECE2),
    );

    // Blok-blok bangunan & taman di peta
    final blockPaint = Paint()..color = const Color(0xFFE7DEC8);
    final parkPaint = Paint()..color = const Color(0xFFD9EDDF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.08, w * 0.34, h * 0.22),
        const Radius.circular(14),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.54, h * 0.06, w * 0.38, h * 0.20),
        const Radius.circular(14),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.56, h * 0.38, w * 0.36, h * 0.28),
        const Radius.circular(14),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.44, w * 0.28, h * 0.26),
        const Radius.circular(14),
      ),
      parkPaint,
    );

    // Jalan raya putih di peta
    final mapRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final gridPath = Path()
      ..moveTo(0, h * 0.34)
      ..lineTo(w, h * 0.34)
      ..moveTo(w * 0.46, 0)
      ..lineTo(w * 0.46, h)
      ..moveTo(w * 0.22, h * 0.74)
      ..lineTo(w * 0.85, h * 0.14);
    canvas.drawPath(gridPath, mapRoadPaint);

    // 2. Rute Pengiriman Oranye Aktif (Dari Toko ke Pelanggan)
    final startPt = Offset(w * 0.24, h * 0.68);
    final midPt1 = Offset(w * 0.46, h * 0.52);
    final midPt2 = Offset(w * 0.46, h * 0.34);
    final destPt = Offset(w * 0.72, h * 0.20);

    final routePath = Path()
      ..moveTo(startPt.dx, startPt.dy)
      ..lineTo(midPt1.dx, midPt1.dy)
      ..lineTo(midPt2.dx, midPt2.dy)
      ..lineTo(destPt.dx, destPt.dy);

    final routeGlowPaint = Paint()
      ..color = AppColors.posOrange.withValues(alpha: 0.25)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(routePath, routeGlowPaint);

    final routeLinePaint = Paint()
      ..color = AppColors.posOrange
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(routePath, routeLinePaint);

    // Titik Toko & Titik Tujuan Pelanggan
    canvas.drawCircle(startPt, 9, Paint()..color = AppColors.loginPrimaryGreen);
    canvas.drawCircle(startPt, 4, Paint()..color = Colors.white);

    canvas.drawCircle(destPt, 13, Paint()..color = AppColors.posOrange);
    canvas.drawCircle(destPt, 5, Paint()..color = Colors.white);

    // Pejalan kaki kecil sedang berjalan di dekat titik tujuan
    final walkOffset = math.sin(phase * math.pi * 2) * 14;
    final walkerPos = destPt + Offset(-34 + walkOffset, -8);
    canvas.drawCircle(
      walkerPos + const Offset(0, -10),
      4,
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawLine(
      walkerPos + const Offset(0, -6),
      walkerPos + const Offset(0, 2),
      Paint()
        ..color = const Color(0xFF1E293B)
        ..strokeWidth = 3,
    );

    // 3. Posisi Motor Skuter Oranye yang Bergerak Mengikuti Rute
    Offset scooterPos;
    if (phase < 0.35) {
      final t = phase / 0.35;
      scooterPos = Offset.lerp(startPt, midPt1, t)!;
    } else if (phase < 0.68) {
      final t = (phase - 0.35) / 0.33;
      scooterPos = Offset.lerp(midPt1, midPt2, t)!;
    } else {
      final t = (phase - 0.68) / 0.32;
      scooterPos = Offset.lerp(midPt2, destPt, t)!;
    }

    // Lingkaran radar berdenyut di sekitar motor kurir
    final pulseRadius = 18.0 + 12.0 * math.sin(phase * math.pi * 4).abs();
    canvas.drawCircle(
      scooterPos,
      pulseRadius,
      Paint()..color = AppColors.posOrange.withValues(alpha: 0.22),
    );

    // Ikon Motor Skuter Oranye di atas rute
    canvas.save();
    canvas.translate(scooterPos.dx, scooterPos.dy);
    canvas.drawCircle(
      Offset.zero,
      17,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset.zero,
      14,
      Paint()..color = AppColors.posOrange,
    );
    // Roda & bodi skuter mini
    canvas.drawCircle(
      const Offset(-5, 4),
      3.5,
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawCircle(
      const Offset(5, 4),
      3.5,
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, -4, 12, 6),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white,
    );
    canvas.restore();

    // 4. Badge Estimasi Waktu "3 min" di samping Motor (Persis Video 2 detik 00:19!)
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: scooterPos + const Offset(44, -22),
        width: 58,
        height: 26,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(badgeRect, Paint()..color = AppColors.posOrange);

    final tp = TextPainter(
      text: const TextSpan(
        text: '3 min',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      scooterPos + Offset(44 - tp.width / 2, -22 - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _LiveDeliveryMapPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

