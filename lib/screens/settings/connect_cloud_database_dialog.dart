import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/local_db_service.dart';

class ConnectCloudDatabaseDialog extends StatefulWidget {
  const ConnectCloudDatabaseDialog({super.key});

  @override
  State<ConnectCloudDatabaseDialog> createState() =>
      _ConnectCloudDatabaseDialogState();
}

class _ConnectCloudDatabaseDialogState
    extends State<ConnectCloudDatabaseDialog> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  bool _isLoading = false;
  bool _obscureKey = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingCredentials();
  }

  Future<void> _loadExistingCredentials() async {
    final creds = await LocalDbService().getCustomSupabaseCredentials();
    if (mounted) {
      setState(() {
        _urlController.text = creds['url'] ?? SupabaseConfig.activeUrl;
        _keyController.text = creds['key'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    final url = _urlController.text.trim();
    final key = _keyController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await SupabaseConfig.connectCustom(url: url, anonKey: key);
      if (success) {
        if (!mounted) return;
        // Reload semua data dari database cloud Supabase
        await Future.wait([
          context.read<ProductProvider>().loadProducts(),
          context.read<CategoryProvider>().loadCategories(),
          context.read<TransactionProvider>().loadTransactions(),
          context.read<AuthProvider>().checkExistingSession(),
        ]);

        setState(() {
          _isLoading = false;
          _successMessage =
              '✓ Berhasil terhubung ke Supabase Cloud! Data sekarang tersinkronisasi otomatis antar HP dan Laptop.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _handleDisconnect() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await SupabaseConfig.disconnectCustom();

    if (!mounted) return;
    await Future.wait([
      context.read<ProductProvider>().loadProducts(),
      context.read<CategoryProvider>().loadCategories(),
      context.read<TransactionProvider>().loadTransactions(),
    ]);

    setState(() {
      _isLoading = false;
      _urlController.clear();
      _keyController.clear();
      _successMessage =
          'Koneksi cloud diputus. Sistem kembali menggunakan Database Lokal Terintegrasi (Permanen & Aman).';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLive = SupabaseConfig.isConfigured;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Dialog
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isLive
                            ? const Color(0xFFDCFCE7)
                            : AppColors.posOrangeLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLive ? Icons.cloud_done_rounded : Icons.cloud_sync_rounded,
                        color: isLive ? AppColors.loginPrimaryGreen : AppColors.posOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Koneksi Database Cloud',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isLive
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isLive
                                    ? 'Supabase PostgreSQL Cloud Aktif'
                                    : 'Database Lokal Terintegrasi (Permanen)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isLive
                                      ? AppColors.loginPrimaryGreen
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Tutup',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Info Box Penjelasan
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Sinkronisasi Data Real-Time Antar Perangkat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Aplikasi ini sudah memiliki Database Lokal Permanen (tambah barang, hapus barang, dan akun tersimpan di HP). '
                        'Jika ingin data tersambung langsung secara online antara HP dan Laptop kasir, masukkan URL & Anon Key dari project Supabase Anda.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Input URL Supabase
                const Text(
                  'Project URL Supabase',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDarkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'https://xxxx.supabase.co',
                    prefixIcon: const Icon(Icons.link_rounded, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.posOrange),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),

                // Input Anon Key Supabase
                const Text(
                  'Supabase Anon Key (Public Key)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDarkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _keyController,
                  obscureText: _obscureKey,
                  decoration: InputDecoration(
                    hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                    prefixIcon: const Icon(Icons.key_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscureKey = !_obscureKey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.posOrange),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),

                // Pesan Error jika gagal
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Pesan Sukses jika berhasil
                if (_successMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: AppColors.loginPrimaryGreen, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(
                              color: AppColors.loginPrimaryGreen,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // Tombol Aksi
                Row(
                  children: [
                    if (isLive) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _handleDisconnect,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorRed,
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Putuskan Cloud'),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleConnect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.posOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.cloud_upload_rounded, size: 18),
                        label: Text(
                          _isLoading ? 'Menghubungkan...' : 'Simpan & Hubungkan Cloud',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
