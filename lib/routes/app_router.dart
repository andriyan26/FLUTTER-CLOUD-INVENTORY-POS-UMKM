import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/post_login_welcome_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/main_shell_screen.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _showSplash = true;
  bool _showPostLoginWelcome = false;
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkExistingSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;

    // Jika baru saja Logout atau klik "Ulangi Animasi Login", putar kembali SplashScreen dari awal
    if (_wasAuthenticated && !isAuthenticated) {
      _showSplash = true;
      _showPostLoginWelcome = false;
    }
    _wasAuthenticated = isAuthenticated;

    Widget currentScreen;
    if (_showSplash) {
      currentScreen = SplashScreen(
        key: const ValueKey('splash_screen'),
        onFinished: () {
          if (mounted) {
            setState(() => _showSplash = false);
          }
        },
      );
    } else if (!isAuthenticated) {
      currentScreen = LoginScreen(
        key: const ValueKey('login_screen'),
        onLoginSuccess: () {
          if (mounted) {
            setState(() => _showPostLoginWelcome = true);
          }
        },
      );
    } else if (_showPostLoginWelcome) {
      currentScreen = PostLoginWelcomeScreen(
        key: const ValueKey('post_login_welcome'),
        onCompleted: () {
          if (mounted) {
            setState(() => _showPostLoginWelcome = false);
          }
        },
      );
    } else {
      currentScreen = const MainShellScreen(key: ValueKey('main_shell'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 480),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.0, 0.06),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: currentScreen,
    );
  }
}
