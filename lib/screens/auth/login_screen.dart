import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController(
    text: 'dailyflutterui@gmail.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '123456',
  );
  final TextEditingController _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _keepSignedIn = true;
  bool _isRegisterMode = false;
  String? _emailLiveError;
  String? _passwordLiveError;

  late final AnimationController _entranceController;
  late final AnimationController _mascotFloatController;
  late final Animation<Offset> _headerSlide;
  late final Animation<Offset> _mascotSlide;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _mascotFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _mascotSlide = Tween<Offset>(
      begin: const Offset(0.85, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
      ),
    );

    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _mascotFloatController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailLiveError = Validators.validateEmailOrUsername(value);
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordLiveError = Validators.validatePassword(value);
    });
  }

  Future<void> _submitAuth() async {
    final emailErr = Validators.validateEmailOrUsername(_emailController.text);
    final passErr = Validators.validatePassword(_passwordController.text);

    setState(() {
      _emailLiveError = emailErr;
      _passwordLiveError = passErr;
    });

    if (emailErr != null || passErr != null) return;

    final authProvider = context.read<AuthProvider>();
    bool success = false;

    if (_isRegisterMode) {
      final name = _nameController.text.trim().isEmpty
          ? 'Admin UMKM'
          : _nameController.text.trim();
      success = await authProvider.signUp(
        fullName: name,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await authProvider.signIn(
        emailOrUsername: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (!mounted) return;
    if (success) {
      widget.onLoginSuccess?.call();
    }
  }

  void _fillDemoCredentials({required bool asAdmin}) {
    setState(() {
      _isRegisterMode = false;
      _emailController.text =
          asAdmin ? 'dailyflutterui@gmail.com' : 'kasir@umkm.id';
      _passwordController.text = '123456';
      _emailLiveError = null;
      _passwordLiveError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isEmailValid =
        _emailController.text.isNotEmpty && _emailLiveError == null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. HEADER HIJAU BERANIMASI + NAMA APLIKASI KITA "CloudPOS." (BUKAN FOODIE!)
            SlideTransition(
              position: _headerSlide,
              child: _buildHeroHeader(),
            ),

            // 2. FORM CONTAINER PUTIH DENGAN ANIMASI STAGGERED SLIDE & FADE
            FadeTransition(
              opacity: _formFade,
              child: SlideTransition(
                position: _formSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isRegisterMode ? 'Create Account' : 'Welcome Back',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDarkSlate,
                              letterSpacing: -0.6,
                            ),
                          ),
                          // Pilihan Cepat Role Admin / Kasir
                          Row(
                            children: [
                              _buildMiniRoleChip(
                                label: 'Admin',
                                active: !_emailController.text
                                    .toLowerCase()
                                    .contains('kasir'),
                                onTap: () => _fillDemoCredentials(asAdmin: true),
                              ),
                              const SizedBox(width: 5),
                              _buildMiniRoleChip(
                                label: 'Kasir',
                                active: _emailController.text
                                    .toLowerCase()
                                    .contains('kasir'),
                                onTap: () =>
                                    _fillDemoCredentials(asAdmin: false),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isRegisterMode) ...[
                        _buildRoundedInputField(
                          controller: _nameController,
                          hintText: 'Nama Lengkap / Nama Toko UMKM',
                          icon: Icons.storefront_outlined,
                          borderColor: AppColors.borderLight,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Input Email or Phone dengan Live Validation seperti di Video 1 (00:08)
                      _buildRoundedInputField(
                        controller: _emailController,
                        hintText: 'Email or phone',
                        icon: Icons.mail_outline_rounded,
                        onChanged: _onEmailChanged,
                        borderColor: _emailLiveError != null
                            ? AppColors.errorRed
                            : (isEmailValid
                                ? AppColors.loginPrimaryGreen
                                : AppColors.borderLight),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: _emailLiveError != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, top: 5),
                                child: Text(
                                  _emailLiveError!,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 12),

                      // Input Password + Toggle Visibility + Helper "Use at least 6 characters"
                      _buildRoundedInputField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        onChanged: _onPasswordChanged,
                        borderColor: _passwordLiveError != null
                            ? AppColors.errorRed
                            : AppColors.loginPrimaryGreen,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 5),
                        child: Text(
                          _passwordLiveError ?? 'Use at least 6 characters',
                          style: TextStyle(
                            color: _passwordLiveError != null
                                ? AppColors.errorRed
                                : AppColors.textMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      if (authProvider.errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.errorRed,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.errorRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // Baris "Keep me signed in" & "Forgot Password?" (Persis Video 1 detik 00:11)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _keepSignedIn = !_keepSignedIn;
                              });
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _keepSignedIn,
                                    activeColor: AppColors.loginPrimaryGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _keepSignedIn = val ?? true;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Keep me signed in',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _fillDemoCredentials(asAdmin: true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Kredensial Demo otomatis diisi (Pass: 123456)',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 30),
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.loginPrimaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Tombol Utama "Log In" Kapsul Hijau dengan Shadow Halus (Persis Video 1)
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF569A30),
                              Color(0xFF3E7622),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x404E8D2A),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _submitAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isRegisterMode ? 'Sign Up' : 'Log In',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // "Or continue with" + Tombol Google & Apple (Persis Video 1)
                      const Center(
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSocialPillButton(
                              label: 'Google',
                              icon: Icons.g_mobiledata_rounded,
                              iconColor: const Color(0xFFEA4335),
                              onTap: () {
                                _fillDemoCredentials(asAdmin: true);
                                _submitAuth();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSocialPillButton(
                              label: 'Apple',
                              icon: Icons.apple_rounded,
                              iconColor: Colors.black,
                              onTap: () {
                                _fillDemoCredentials(asAdmin: false);
                                _submitAuth();
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Footer "Don't have an account? Sign Up"
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isRegisterMode = !_isRegisterMode;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                              children: [
                                TextSpan(
                                  text: _isRegisterMode
                                      ? 'Already have an account? '
                                      : "Don't have an account? ",
                                ),
                                TextSpan(
                                  text: _isRegisterMode ? 'Log In' : 'Sign Up',
                                  style: const TextStyle(
                                    color: AppColors.loginPrimaryGreen,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      height: 238,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF285214),
            Color(0xFF3E7622),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Lingkaran dekorasi lembut di kanan
          Positioned(
            right: -25,
            top: 20,
            child: Container(
              width: 175,
              height: 175,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 42, 16, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Kiri: Brand Aplikasi Kita "CloudPOS." (Bukan Foodie!)
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.9,
                          ),
                          children: [
                            TextSpan(
                              text: 'Cloud',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'POS.',
                              style: TextStyle(color: Color(0xFFA3E635)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Cloud Inventory & POS',
                          style: TextStyle(
                            color: Color(0xFFD9F99D),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kelola stok & kasir UMKM,\nlangsung dari genggaman.',
                        style: TextStyle(
                          color: Color(0xEEFFFFFF),
                          fontSize: 12.5,
                          height: 1.38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Kanan: Ilustrasi Skuter Kurir Beranimasi Melayang Halus
                Expanded(
                  flex: 5,
                  child: SlideTransition(
                    position: _mascotSlide,
                    child: AnimatedBuilder(
                      animation: _mascotFloatController,
                      builder: (context, child) {
                        final dy = math.sin(
                              _mascotFloatController.value * math.pi,
                            ) *
                            -4.5;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        );
                      },
                      child: const Center(
                        child: CloudPosScooterIllustration(size: 132),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRoleChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.loginPrimaryGreen : AppColors.loginSoftMint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColors.loginHeaderDarkGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color borderColor,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 1.6),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textDarkSlate,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialPillButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.borderLight, width: 1.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDarkSlate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
