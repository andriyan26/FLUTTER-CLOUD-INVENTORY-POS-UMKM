import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  @override
  void dispose() {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selamat datang kembali, ${authProvider.currentUser?.fullName ?? 'User'}!',
          ),
          backgroundColor: AppColors.loginPrimaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. HEADER HIJAU TUA + MASKOT SKUTER (PERSIS VIDEO 1: KONSEP LOGIN.mp4)
            _buildVideo1HeroHeader(),

            // 2. FORM CONTAINER PUTIH
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRegisterMode ? 'Create Account' : 'Welcome Back',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDarkSlate,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Banner Info Demo Mode / Quick Switch Role (Admin vs Kasir)
                  _buildQuickAccountPills(authProvider.isDemoMode),
                  const SizedBox(height: 14),

                  if (_isRegisterMode) ...[
                    _buildRoundedInputField(
                      controller: _nameController,
                      hintText: 'Full Name (e.g. Toko Berkah)',
                      icon: Icons.person_outline_rounded,
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
                  if (_emailLiveError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 5),
                      child: Text(
                        _emailLiveError!,
                        style: const TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

                  const SizedBox(height: 10),

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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Akun Demo: dailyflutterui@gmail.com | Pass: 123456',
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
                            fontWeight: FontWeight.w700,
                            color: AppColors.loginPrimaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Tombol Utama "Log In" Berbentuk Kapsul Hijau (Persis Video 1)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _submitAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.loginPrimaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
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
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
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
          ],
        ),
      ),
    );
  }

  Widget _buildVideo1HeroHeader() {
    return Container(
      height: 228,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.loginHeaderDarkGreen,
            AppColors.loginHeaderMidGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Ornamen kurva bawah halus seperti di Video 1
          Positioned(
            right: -30,
            bottom: -40,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 44, 18, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Kiri: Brand Title & Tagline (Persis "Foodie. Hot meals, right at your door.")
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
                            letterSpacing: -0.8,
                          ),
                          children: [
                            TextSpan(
                              text: 'Food',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'ie.',
                              style: TextStyle(color: Color(0xFFA3E635)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Cloud Inventory & POS UMKM',
                          style: TextStyle(
                            color: Color(0xFFD9F99D),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kelola stok & kasir,\nlangsung dari genggaman.',
                        style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 12.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Kanan: Ilustrasi Kurir Skuter Hijau (Persis Video 1)
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Container(
                      width: 122,
                      height: 122,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delivery_dining_rounded,
                        size: 78,
                        color: Color(0xFFBEF264),
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

  Widget _buildQuickAccountPills(bool isDemoMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.loginSoftMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 15,
            color: AppColors.loginPrimaryGreen,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isDemoMode ? 'Mode Demo Cepat:' : 'Pilih Role Uji:',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.loginHeaderDarkGreen,
              ),
            ),
          ),
          InkWell(
            onTap: () => _fillDemoCredentials(asAdmin: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.loginPrimaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _fillDemoCredentials(asAdmin: false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.loginPrimaryGreen),
              ),
              child: const Text(
                'Kasir',
                style: TextStyle(
                  color: AppColors.loginPrimaryGreen,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 1.5),
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
          border: Border.all(color: AppColors.borderLight, width: 1.2),
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
