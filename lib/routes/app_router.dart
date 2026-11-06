import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/main_shell_screen.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkExistingSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onFinished: () {
          if (mounted) {
            setState(() => _showSplash = false);
          }
        },
      );
    }

    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      child: isAuthenticated
          ? const MainShellScreen(key: ValueKey('main_shell'))
          : const LoginScreen(key: ValueKey('login_screen')),
    );
  }
}

