import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ui_frame_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final frameProvider = context.watch<UiFrameProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil & Pengaturan Cloud',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDarkSlate,
                ),
              ),
              const SizedBox(height: 14),

              // Kartu Profil Pengguna
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.posOrange,
                      child: Text(
                        (user?.fullName.isNotEmpty == true)
                            ? user!.fullName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Pengguna UMKM',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                          Text(
                            user?.email ?? 'dailyflutterui@gmail.com',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.loginSoftMint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ROLE: ${(user?.role ?? 'admin').toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.loginPrimaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Status Koneksi Supabase & GitHub Cloud
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Cloud & Environment',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatusRow(
                      icon: Icons.storage_rounded,
                      title: 'Database Backend',
                      value: SupabaseConfig.isConfigured
                          ? 'Supabase PostgreSQL Live'
                          : 'Smart Cloud Demo Mode (Siap Hubung Supabase)',
                    ),
                    const Divider(height: 18),
                    _buildStatusRow(
                      icon: Icons.phone_iphone_rounded,
                      title: 'Resolusi Referensi Utama',
                      value: 'iPhone 13 (390 × 844 px) + Responsive Web',
                    ),
                    const Divider(height: 18),
                    _buildStatusRow(
                      icon: Icons.cloud_done_outlined,
                      title: 'GitHub Codespaces & CI/CD',
                      value: 'Terkonfigurasi (.devcontainer & GitHub Actions)',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pilihan Mode Tampilan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mode Simulator Layar (Browser Preview)',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('iPhone 13 (390×844)'),
                          selected: frameProvider.viewportMode ==
                              ViewportMode.iphone13,
                          onSelected: (_) => frameProvider
                              .setViewportMode(ViewportMode.iphone13),
                        ),
                        ChoiceChip(
                          label: const Text('Tablet (768×1024)'),
                          selected:
                              frameProvider.viewportMode == ViewportMode.tablet,
                          onSelected: (_) =>
                              frameProvider.setViewportMode(ViewportMode.tablet),
                        ),
                        ChoiceChip(
                          label: const Text('Full Desktop'),
                          selected: frameProvider.viewportMode ==
                              ViewportMode.desktopFull,
                          onSelected: (_) => frameProvider
                              .setViewportMode(ViewportMode.desktopFull),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Tombol Logout (Menghapus Session)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Keluar / Logout Session',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.posOrange, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDarkSlate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

