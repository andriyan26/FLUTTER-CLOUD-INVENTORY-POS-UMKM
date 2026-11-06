import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/smooth_staggered_reveal.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _keepSignedIn = true;
  bool _isRegisterMode = false;
  String? _emailLiveError;
  String? _passwordLiveError;

  late final AnimationController _scooterEnterFromRightController;
  late final AnimationController _mascotFloatController;
  late final AnimationController _wheelSpinController;
  late final AnimationController _buttonPulseController;
  late final Animation<Offset> _headerScooterSlide;

  @override
  void initState() {
    super.initState();

    // Animasi motor di header atas berjalan masuk dari KANAN ke posisinya (Persis KONSEP LOGIN.mp4 detik 00:05 - 00:07)
    _scooterEnterFromRightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );

    _headerScooterSlide = Tween<Offset>(
      begin: const Offset(1.85, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _scooterEnterFromRightController,
        curve: Curves.easeOutBack,
      ),
    );

    _mascotFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _wheelSpinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..repeat();

    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.985,
      upperBound: 1.015,
    )..repeat(reverse: true);

    // Mulai jalankan motor dari kanan ke posisinya sesaat setelah header muncul
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) {
        _scooterEnterFromRightController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scooterEnterFromRightController.dispose();
    _mascotFloatController.dispose();
    _wheelSpinController.dispose();
    _buttonPulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailLiveError =
          value.isEmpty ? null : Validators.validateEmailOrUsername(value);
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordLiveError =
          value.isEmpty ? null : Validators.validatePassword(value);
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

  Future<void> _handleSocialQuickSignIn({required String providerName}) async {
    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim().isNotEmpty
        ? _emailController.text.trim()
        : 'dailyflutterui@gmail.com';
    final pass = _passwordController.text.length >= 6
        ? _passwordController.text
        : '123456';

    final success = await authProvider.signIn(
      emailOrUsername: email,
      password: pass,
    );
    if (!mounted) return;
    if (success) {
      widget.onLoginSuccess?.call();
    }
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
            // 1. HEADER HIJAU MEWAH DENGAN MOTOR BERJALAN DARI KANAN KE POSISINYA
            SmoothStaggeredReveal(
              index: 0,
              beginOffset: const Offset(0, -0.22),
              duration: const Duration(milliseconds: 680),
              child: _buildHeroHeader(),
            ),

            // 2. FORM CONTAINER PUTIH BERSIH TANPA KETERANGAN AKUN DEMO (Persis KONSEP LOGIN.mp4)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmoothStaggeredReveal(
                    index: 1,
                    child: Text(
                      _isRegisterMode ? 'Create Account' : 'Welcome Back',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDarkSlate,
                        letterSpacing: -0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  if (_isRegisterMode) ...[
                    SmoothStaggeredReveal(
                      index: 2,
                      child: _buildRoundedInputField(
                        controller: _nameController,
                        hintText: 'Full Name / Store Name',
                        icon: Icons.storefront_outlined,
                        borderColor: AppColors.borderLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Input Email or Phone + Validasi Real-Time Halus (Persis KONSEP LOGIN.mp4)
                  SmoothStaggeredReveal(
                    index: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Input Password + Toggle Visibility
                  SmoothStaggeredReveal(
                    index: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRoundedInputField(
                          controller: _passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          onChanged: _onPasswordChanged,
                          onSubmitted: (_) => _submitAuth(),
                          borderColor: _passwordLiveError != null
                              ? AppColors.errorRed
                              : (_passwordController.text.length >= 6
                                  ? AppColors.loginPrimaryGreen
                                  : AppColors.borderLight),
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
                      ],
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

                  // Baris "Keep me signed in" & "Forgot Password?"
                  SmoothStaggeredReveal(
                    index: 4,
                    child: Row(
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.loginPrimaryGreen,
                                content: Text(
                                  'Silakan masukkan email & password Anda untuk masuk.',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
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
                  ),

                  const SizedBox(height: 14),

                  // Tombol Utama "Log In" Kapsul Hijau dengan Pulse Halus
                  SmoothStaggeredReveal(
                    index: 5,
                    child: ScaleTransition(
                      scale: _buttonPulseController,
                      child: Container(
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
                              color: Color(0x454E8D2A),
                              blurRadius: 18,
                              offset: Offset(0, 7),
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
                    ),
                  ),

                  const SizedBox(height: 18),

                  // "Or continue with" + Tombol Google & Apple
                  SmoothStaggeredReveal(
                    index: 6,
                    child: Column(
                      children: [
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
                                onTap: () => _handleSocialQuickSignIn(
                                  providerName: 'Google',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSocialPillButton(
                                label: 'Apple',
                                icon: Icons.apple_rounded,
                                iconColor: Colors.black,
                                onTap: () => _handleSocialQuickSignIn(
                                  providerName: 'Apple',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                                    text:
                                        _isRegisterMode ? 'Log In' : 'Sign Up',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        height: 242,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF234A10),
              Color(0xFF3E7622),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: 24,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFFA3E635).withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 42, 14, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Kiri: Brand Aplikasi Kita "CloudPOS."
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 31,
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
                        const SizedBox(height: 8),
                        const Text(
                          'Smart inventory, delivered fast,\nright to your store door.',
                          style: TextStyle(
                            color: Color(0xF0FFFFFF),
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Kanan: Motor Kurir Hijau Berjalan Masuk dari KANAN ke Posisinya Menghadap Kiri (Persis KONSEP LOGIN.mp4 detik 00:05-00:07)
                  Expanded(
                    flex: 5,
                    child: SlideTransition(
                      position: _headerScooterSlide,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _mascotFloatController,
                          _wheelSpinController,
                          _scooterEnterFromRightController,
                        ]),
                        builder: (context, _) {
                          final isDrivingIn =
                              _scooterEnterFromRightController.value < 0.96;
                          final dy = math.sin(
                                _mascotFloatController.value * math.pi,
                              ) *
                              -4.5;
                          return Transform.translate(
                            offset: Offset(0, dy),
                            child: Center(
                              child: CloudPosScooterIllustration(
                                size: 138,
                                flipHorizontal: true,
                                wheelPhase: isDrivingIn
                                    ? _wheelSpinController.value
                                    : _mascotFloatController.value * 0.25,
                                showSpeedLines: isDrivingIn,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    ValueChanged<String>? onSubmitted,
    Widget? suffixIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 1.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
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
          border: Border.all(color: AppColors.borderLight, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
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
