import 'dart:async';
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
  bool _userInteractedManually = false;
  String? _emailLiveError;
  String? _passwordLiveError;

  Timer? _autoTypeTimer;
  late final AnimationController _mascotFloatController;
  late final AnimationController _buttonPulseController;

  @override
  void initState() {
    super.initState();
    _mascotFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.98,
      upperBound: 1.02,
    )..repeat(reverse: true);

    // Jalankan animasi pengetikan halus otomatis seperti di KONSEP LOGIN.mp4 (00:07 - 00:13)
    Future.delayed(const Duration(milliseconds: 850), () {
      if (mounted && !_userInteractedManually) {
        _startSmoothAutoTypingDemo();
      }
    });
  }

  void _startSmoothAutoTypingDemo() {
    const targetEmail = 'dailyflutterui@gmail.com';
    const targetPass = '123456';
    int emailIdx = 0;
    int passIdx = 0;

    _autoTypeTimer = Timer.periodic(const Duration(milliseconds: 48), (timer) {
      if (!mounted || _userInteractedManually) {
        timer.cancel();
        return;
      }

      if (emailIdx < targetEmail.length) {
        emailIdx++;
        final sub = targetEmail.substring(0, emailIdx);
        _emailController.value = TextEditingValue(
          text: sub,
          selection: TextSelection.collapsed(offset: sub.length),
        );
        setState(() {
          _emailLiveError = Validators.validateEmailOrUsername(sub);
        });
      } else if (passIdx < targetPass.length) {
        passIdx++;
        final subPass = targetPass.substring(0, passIdx);
        _passwordController.value = TextEditingValue(
          text: subPass,
          selection: TextSelection.collapsed(offset: subPass.length),
        );
        setState(() {
          _passwordLiveError = Validators.validatePassword(subPass);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _stopAutoTypeOnUserTouch() {
    if (!_userInteractedManually) {
      _userInteractedManually = true;
      _autoTypeTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _autoTypeTimer?.cancel();
    _mascotFloatController.dispose();
    _buttonPulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    _stopAutoTypeOnUserTouch();
    setState(() {
      _emailLiveError = Validators.validateEmailOrUsername(value);
    });
  }

  void _onPasswordChanged(String value) {
    _stopAutoTypeOnUserTouch();
    setState(() {
      _passwordLiveError = Validators.validatePassword(value);
    });
  }

  Future<void> _submitAuth() async {
    _stopAutoTypeOnUserTouch();
    if (_emailController.text.trim().isEmpty) {
      _emailController.text = 'dailyflutterui@gmail.com';
    }
    if (_passwordController.text.isEmpty) {
      _passwordController.text = '123456';
    }

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
    _stopAutoTypeOnUserTouch();
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
            // 1. HEADER HIJAU MEWAH DENGAN TRANSISI PERLAHAN & MASKOT SKUTER
            SmoothStaggeredReveal(
              index: 0,
              beginOffset: const Offset(0, -0.25),
              duration: const Duration(milliseconds: 780),
              child: _buildHeroHeader(),
            ),

            // 2. FORM CONTAINER PUTIH DENGAN KEMUNCULAN DATA SECARA PERLAHAN (STAGGERED SMOOTH)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmoothStaggeredReveal(
                    index: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isRegisterMode ? 'Create Account' : 'Welcome Back',
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDarkSlate,
                            letterSpacing: -0.7,
                          ),
                        ),
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
                              onTap: () => _fillDemoCredentials(asAdmin: false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_isRegisterMode) ...[
                    SmoothStaggeredReveal(
                      index: 2,
                      child: _buildRoundedInputField(
                        controller: _nameController,
                        hintText: 'Nama Lengkap / Nama Toko UMKM',
                        icon: Icons.storefront_outlined,
                        borderColor: AppColors.borderLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Input Email or Phone + Validasi Real-Time Halus
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
                          duration: const Duration(milliseconds: 240),
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

                  const SizedBox(height: 12),

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
                            _fillDemoCredentials(asAdmin: true);
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
    return Container(
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
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
            padding: const EdgeInsets.fromLTRB(24, 42, 16, 18),
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
                        'Kelola stok & kasir UMKM,\nlangsung di pintu toko Anda.',
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
                // Kanan: Ilustrasi Vektor Kurir Skuter Hijau Melayang Halus
                Expanded(
                  flex: 5,
                  child: AnimatedBuilder(
                    animation: _mascotFloatController,
                    builder: (context, child) {
                      final dy = math.sin(
                            _mascotFloatController.value * math.pi,
                          ) *
                          -5.0;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: child,
                      );
                    },
                    child: const Center(
                      child: CloudPosScooterIllustration(size: 138),
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
        duration: const Duration(milliseconds: 220),
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
        onTap: _stopAutoTypeOnUserTouch,
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
