import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Layar Transisi Animasi Setelah Login Persis VIDEO 2 (KONSEP SETELAH LOGIN.mp4 detik 00:00 - 00:02)
/// Menampilkan visual kurir kota emas, logo 3D tas belanja di atas, dan tombol kapsul bawah
/// "Commencer / Mulai Kasir" yang melebar secara elastis menjadi tanda centang ganda (✓✓) lalu masuk ke Dashboard!
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
    with SingleTickerProviderStateMixin {
  bool _isExpandingButton = false;
  bool _showDoubleCheck = false;

  @override
  void initState() {
    super.initState();
    // Otomatis menjalankan animasi morphing tombol seperti di Video 2 jika pengguna tidak menekan manual dalam 1.4 detik
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted && !_isExpandingButton) {
        _triggerLaunchTransition();
      }
    });
  }

  Future<void> _triggerLaunchTransition() async {
    if (_isExpandingButton) return;
    setState(() {
      _isExpandingButton = true;
    });
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
          // 1. Background Golden-Hour Street Scooter (Persis Video 2 detik 00:00)
          Image.network(
            'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=900&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFF9A3412)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Overlay gradasi hangat keemasan seperti di Video 2
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE0F2FE).withValues(alpha: 0.72),
                  const Color(0xFFF97316).withValues(alpha: 0.35),
                  const Color(0xFF431407).withValues(alpha: 0.78),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. Logo 3D Tas Belanja Oranye + Nama Aplikasi Kita "CloudPOS." di Bagian Atas (Persis Video 2 detik 00:00)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.75, end: 1.0),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF6B35),
                                Color(0xFFE84118),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55F05A28),
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
                                size: 44,
                                color: Colors.white,
                              ),
                              Positioned(
                                bottom: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 12,
                                    color: AppColors.posOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'CloudPOS',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.posOrange,
                            letterSpacing: -0.8,
                            shadows: [
                              Shadow(
                                color: Colors.white70,
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Cloud Inventory & POS UMKM',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 3. Tombol Slider Bawah "Commencer / Mulai Kasir" yang Melebar Jadi "✓✓" (Persis Video 2 detik 00:01)
                  GestureDetector(
                    onTap: _triggerLaunchTransition,
                    child: Container(
                      height: 62,
                      width: double.infinity,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 1.4,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Center(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: _isExpandingButton ? 0.0 : 1.0,
                                  child: const Text(
                                    'Mulai Kasir • Commencer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
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
                                      color: Color(0x66F05A28),
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
                                  duration: const Duration(milliseconds: 200),
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
