import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbus/features/auth/presentation/pages/login_screen.dart';
import 'package:nimbus/features/auth/presentation/pages/passcode_setup_screen.dart';
import 'package:nimbus/features/auth/data/services/local_auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authService = ref.read(localAuthServiceProvider);
      final isSetup = await authService.isAuthSetup();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                isSetup ? const LoginScreen() : const PasscodeSetupScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nimbus Logo
            Image.asset(
              'assets/images/app_logo.png',
              width: 139.7,
              height: 90.42,
            ),
            const Text(
              'Nimbus',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
