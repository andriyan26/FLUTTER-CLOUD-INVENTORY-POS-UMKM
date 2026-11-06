import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/custom_cached_image.dart';
import '../../core/widgets/smooth_staggered_reveal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/ui_frame_provider.dart';
import '../../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  bool _isUploadingAvatar = false;

  static const List<Map<String, String>> _studioAvatars = [
    {
      'label': 'Founder',
      'url':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
    },
    {
      'label': 'Executive',
      'url':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
    },
    {
      'label': 'Manager',
      'url':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
    },
    {
      'label': 'Barista',
      'url':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=300&q=80',
    },
    {
      'label': 'Cashier',
      'url':
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=300&q=80',
    },
  ];

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingAvatar = true);
      final bytes = await picked.readAsBytes();
      final uploadedUrl = await _storageService.uploadAvatarImage(
        bytes: bytes,
        fileName: picked.name,
      );

      if (!mounted) return;
      await context.read<AuthProvider>().updateAvatarUrl(uploadedUrl);
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.loginPrimaryGreen,
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Foto profil berhasil diunggah & diperbarui!',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.errorRed,
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _openEditProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileBottomSheet(
        onPickImageFromDevice: _pickAndUploadAvatar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final frameProvider = context.watch<UiFrameProvider>();
    final productProvider = context.watch<ProductProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER ATAS
              SmoothStaggeredReveal(
                index: 0,
                beginOffset: const Offset(0, -0.15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil & Pengaturan Cloud',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDarkSlate,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Kelola identitas toko, foto profil & preferensi POS',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _openEditProfileModal(context),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.posOrangeLight,
                      ),
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.posOrange,
                        size: 22,
                      ),
                      tooltip: 'Edit Profil',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 1. HERO EXECUTIVE PROFILE & STORE BANNER CARD (MEWAH & INTERAKTIF)
              SmoothStaggeredReveal(
                index: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF153423),
                        Color(0xFF245336),
                        Color(0xFF0F172A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33153423),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Dekorasi Glow Lingkaran Halus
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                AppColors.posOrange.withValues(alpha: 0.16),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -25,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.loginPrimaryGreen
                                .withValues(alpha: 0.14),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Avatar dengan Ring Menyala & Tombol Kamera Upload
                                GestureDetector(
                                  onTap: _isUploadingAvatar
                                      ? null
                                      : _pickAndUploadAvatar,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppColors.posOrange,
                                              Color(0xFFA3E635),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.posOrange
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: _isUploadingAvatar
                                            ? Container(
                                                width: 68,
                                                height: 68,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF1E293B),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child:
                                                    const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : CustomAvatarImage(
                                                avatarUrl:
                                                    user?.avatarUrl ?? '',
                                                fullName:
                                                    user?.fullName ?? 'Andriyan',
                                                size: 68,
                                              ),
                                      ),
                                      Positioned(
                                        bottom: -2,
                                        right: -2,
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: AppColors.posOrange,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: Colors.white,
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              user?.fullName ??
                                                  'Andriyan (Admin UMKM)',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16.5,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: Color(0xFF4ADE80),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user?.storeName ??
                                            'CloudPOS • Cabang Utama UMKM',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFBEF264),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user?.bio ??
                                            'Founder & Senior Store Manager',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.loginPrimaryGreen
                                                  .withValues(alpha: 0.25),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: const Color(0xFF4ADE80)
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            child: Text(
                                              'ROLE: ${(user?.role ?? 'admin').toUpperCase()}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF86EFAC),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'SHIFT: ONLINE',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildHeroContactRow(
                                    Icons.alternate_email_rounded,
                                    user?.email ?? 'dailyflutterui@gmail.com',
                                  ),
                                  const SizedBox(height: 5),
                                  _buildHeroContactRow(
                                    Icons.phone_iphone_rounded,
                                    user?.phoneNumber ?? '+62 812-8899-2026',
                                  ),
                                  const SizedBox(height: 5),
                                  _buildHeroContactRow(
                                    Icons.storefront_rounded,
                                    user?.storeAddress ??
                                        'Jl. Asia Afrika No. 88, Kota Bandung',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 2 Tombol Aksi Cepat: Upload Foto & Edit Profil
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isUploadingAvatar
                                        ? null
                                        : _pickAndUploadAvatar,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.white
                                            .withValues(alpha: 0.35),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 16,
                                    ),
                                    label: Text(
                                      _isUploadingAvatar
                                          ? 'Mengunggah...'
                                          : 'Upload Foto',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _openEditProfileModal(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.posOrange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      size: 15,
                                    ),
                                    label: const Text(
                                      'Edit Profil & Toko',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 2. GALERI AVATAR INSTAN & UPLOAD FOTO DARI PERANGKAT
              SmoothStaggeredReveal(
                index: 2,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Foto Profil & Avatar Studio',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                          InkWell(
                            onTap: _isUploadingAvatar
                                ? null
                                : _pickAndUploadAvatar,
                            child: const Text(
                              '+ Pilih File Galeri',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.posOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 68,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // Tombol Upload dari Laptop/HP
                            GestureDetector(
                              onTap: _isUploadingAvatar
                                  ? null
                                  : _pickAndUploadAvatar,
                              child: Container(
                                width: 58,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: AppColors.posOrangeLight,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.posOrange,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo_rounded,
                                        color: AppColors.posOrange,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Upload',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.posOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ..._studioAvatars.map((item) {
                              final url = item['url']!;
                              final label = item['label']!;
                              final isSelected = user?.avatarUrl == url;
                              return GestureDetector(
                                onTap: () {
                                  context
                                      .read<AuthProvider>()
                                      .updateAvatarUrl(url);
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration:
                                          const Duration(milliseconds: 900),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor:
                                          AppColors.loginPrimaryGreen,
                                      content: Text(
                                        'Avatar "$label" berhasil diterapkan!',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 58,
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.loginPrimaryGreen
                                                : Colors.transparent,
                                            width: 2.2,
                                          ),
                                        ),
                                        child: CustomAvatarImage(
                                          avatarUrl: url,
                                          fullName: label,
                                          size: 42,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: isSelected
                                              ? FontWeight.w900
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.loginPrimaryGreen
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 3. RINGKASAN PERFORMA SHIFT KASIR & TOKO
              SmoothStaggeredReveal(
                index: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMiniMetricCard(
                        icon: Icons.payments_rounded,
                        label: 'Omzet Shift',
                        value: CurrencyFormatter.formatCompactRupiah(
                          txProvider.todaySalesTotal,
                        ),
                        color: AppColors.loginPrimaryGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMiniMetricCard(
                        icon: Icons.receipt_long_rounded,
                        label: 'Transaksi',
                        value: '${txProvider.todayTransactionsCount} Nota',
                        color: AppColors.posOrange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMiniMetricCard(
                        icon: Icons.inventory_2_rounded,
                        label: 'Katalog Aktif',
                        value: '${productProvider.totalProductsCount} SKU',
                        color: AppColors.primaryIndigo,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. PREFERENSI OPERASIONAL KASIR & STRUK (INTERAKTIF)
              SmoothStaggeredReveal(
                index: 4,
                child: Container(
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
                        'Preferensi Kasir & Struk UMKM',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSwitchTile(
                        icon: Icons.store_mall_directory_rounded,
                        title: 'Cetak Header & Alamat Toko di Struk',
                        subtitle:
                            'Tampilkan nama cabang & kontak pada nota pelanggan',
                        value: auth.printStoreHeaderOnReceipt,
                        onChanged: auth.togglePrintStoreHeader,
                      ),
                      const Divider(height: 12),
                      _buildSwitchTile(
                        icon: Icons.percent_rounded,
                        title: 'Hitung Pajak PPN UMKM (11%)',
                        subtitle:
                            'Tambahkan informasi PPN pada ringkasan pembayaran',
                        value: auth.enableTaxPpn,
                        onChanged: auth.toggleTaxPpn,
                      ),
                      const Divider(height: 12),
                      _buildSwitchTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Peringatan Otomatis Stok Menipis',
                        subtitle: 'Beri highlight kuning saat stok <= 10 unit',
                        value: auth.enableLowStockAlert,
                        onChanged: auth.toggleLowStockAlert,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 5. STATUS KONEKSI SUPABASE & GITHUB ACTIONS CI/CD
              SmoothStaggeredReveal(
                index: 5,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status Cloud & CI/CD Pipeline',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.loginSoftMint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'ALL CHECKS PASSING ✓',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.loginPrimaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        icon: Icons.storage_rounded,
                        title: 'Database & Storage Backend',
                        value: SupabaseConfig.isConfigured
                            ? 'Supabase PostgreSQL & Storage Live'
                            : 'Smart Cloud Demo Mode + Direct Upload Ready',
                      ),
                      const Divider(height: 18),
                      _buildStatusRow(
                        icon: Icons.phone_iphone_rounded,
                        title: 'Resolusi Referensi Utama',
                        value: 'iPhone 13 (390 × 844 px) + Responsive Web',
                      ),
                      const Divider(height: 18),
                      _buildStatusRow(
                        icon: Icons.verified_user_outlined,
                        title: 'GitHub Actions & Pages Deployment',
                        value: 'Aktif • Flutter Analyze, Test & Web Deploy Hijau',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 6. PILIHAN MODE SIMULATOR LAYAR
              SmoothStaggeredReveal(
                index: 6,
                child: Container(
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
                        runSpacing: 8,
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
                            selected: frameProvider.viewportMode ==
                                ViewportMode.tablet,
                            onSelected: (_) => frameProvider
                                .setViewportMode(ViewportMode.tablet),
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
              ),

              const SizedBox(height: 20),

              // 7. TOMBOL KELUAR / LOGOUT SESSION
              SmoothStaggeredReveal(
                index: 7,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFFBEF264),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textDarkSlate,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.posOrangeLight,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.posOrange, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDarkSlate,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.loginPrimaryGreen,
          onChanged: onChanged,
        ),
      ],
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
                  fontSize: 12.5,
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

class _EditProfileBottomSheet extends StatefulWidget {
  final Future<void> Function() onPickImageFromDevice;

  const _EditProfileBottomSheet({
    required this.onPickImageFromDevice,
  });

  @override
  State<_EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _storeNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _avatarUrlCtrl;
  late String _selectedRole;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _fullNameCtrl = TextEditingController(text: user?.fullName ?? 'Andriyan');
    _storeNameCtrl = TextEditingController(
      text: user?.storeName ?? 'CloudPOS • Cabang Utama UMKM',
    );
    _emailCtrl = TextEditingController(
      text: user?.email ?? 'dailyflutterui@gmail.com',
    );
    _phoneCtrl = TextEditingController(
      text: user?.phoneNumber ?? '+62 812-8899-2026',
    );
    _addressCtrl = TextEditingController(
      text: user?.storeAddress ?? 'Jl. Asia Afrika No. 88, Kota Bandung',
    );
    _bioCtrl = TextEditingController(
      text: user?.bio ?? 'Founder & Senior Store Manager',
    );
    _avatarUrlCtrl = TextEditingController(
      text: (user?.avatarUrl.startsWith('http') == true)
          ? user!.avatarUrl
          : '',
    );
    _selectedRole = user?.role ?? 'admin';
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _storeNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    _avatarUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final customUrl = _avatarUrlCtrl.text.trim();

    final ok = await auth.updateProfile(
      fullName: _fullNameCtrl.text,
      email: _emailCtrl.text,
      phoneNumber: _phoneCtrl.text,
      storeName: _storeNameCtrl.text,
      storeAddress: _addressCtrl.text,
      bio: _bioCtrl.text,
      role: _selectedRole,
      avatarUrl: customUrl.isNotEmpty ? customUrl : auth.currentUser?.avatarUrl,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.loginPrimaryGreen,
          content: Text(
            'Profil & identitas toko berhasil disimpan!',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profil & Identitas Toko',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDarkSlate,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bagian Upload Foto Profil
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    CustomAvatarImage(
                      avatarUrl: user?.avatarUrl ?? '',
                      fullName: _fullNameCtrl.text,
                      size: 56,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Foto Profil Anda',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const Text(
                            'Pilih foto dari Laptop/HP (JPG, PNG, WEBP)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await widget.onPickImageFromDevice();
                                if (mounted) {
                                  _avatarUrlCtrl.clear();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.posOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(
                                Icons.upload_file_rounded,
                                size: 15,
                              ),
                              label: const Text(
                                'Pilih Gambar dari Perangkat',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
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

              const SizedBox(height: 12),

              TextFormField(
                controller: _fullNameCtrl,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama wajib diisi'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap Pengguna *',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _storeNameCtrl,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama toko wajib diisi'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Nama Toko / Cabang UMKM *',
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email Akun',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'No. WhatsApp',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Alamat Toko (Tercetak di Struk Kasir)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jabatan / Bio Singkat',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 10),

              // Role Selector (Admin / Kasir)
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                items: const [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin UMKM (Akses Penuh Katalog & Laporan)'),
                  ),
                  DropdownMenuItem(
                    value: 'kasir',
                    child: Text('Kasir (Mode Fokus Transaksi POS)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRole = val);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Role Akses Sistem',
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.loginPrimaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(
                    _isSaving ? 'Menyimpan...' : 'Simpan Perubahan Profil',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
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
}
