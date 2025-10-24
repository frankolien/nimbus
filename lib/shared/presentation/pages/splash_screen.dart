import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbus/features/wallet/presentation/pages/wallet_connection_screen.dart';
import 'package:nimbus/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:nimbus/features/wallet/domain/entities/wallet.dart';
import 'package:nimbus/shared/presentation/pages/main_navigation_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkWalletAndNavigate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _checkWalletAndNavigate() async {
    _timer = Timer(const Duration(seconds: 2), () async {
      if (mounted && !_hasNavigated) {
        // Try to load existing wallet first
        final walletStateNotifier = ref.read(walletStateProvider.notifier);

        try {
          // Attempt to connect to existing wallet
          await walletStateNotifier.connectWallet();

          // The listener will handle navigation when the state updates
          print('🔍 Attempted to connect wallet, waiting for state update...');
        } catch (e) {
          print('⚠️ Error loading wallet on startup: $e');
          if (mounted && !_hasNavigated) {
            _hasNavigated = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const WalletConnectionScreen(),
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for wallet state changes
    ref.listen<AsyncValue<Wallet?>>(walletStateProvider, (previous, next) {
      if (_hasNavigated) return;

      if (next.hasValue && next.value != null) {
        _hasNavigated = true;
        print('✅ Wallet connected via listener, navigating to main app');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      } else if (next.hasError) {
        _hasNavigated = true;
        print(
            '❌ Wallet connection failed via listener, navigating to wallet creation');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WalletConnectionScreen(),
          ),
        );
      }
    });

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
