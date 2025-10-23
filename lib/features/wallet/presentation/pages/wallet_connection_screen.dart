import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbus/shared/presentation/pages/main_navigation_screen.dart';
import 'package:nimbus/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:nimbus/features/wallet/domain/entities/wallet.dart';

class WalletConnectionScreen extends ConsumerStatefulWidget {
  const WalletConnectionScreen({super.key});

  @override
  ConsumerState<WalletConnectionScreen> createState() =>
      _WalletConnectionScreenState();
}

class _WalletConnectionScreenState
    extends ConsumerState<WalletConnectionScreen> {
  Future<void> _connectWallet() async {
    try {
      final walletStateNotifier = ref.read(walletStateProvider.notifier);
      await walletStateNotifier.connectWallet();

      // Navigate to main app after successful connection
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wallet setup failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for wallet connection state changes
    ref.listen<AsyncValue<Wallet?>>(walletStateProvider, (previous, next) {
      if (next.hasValue && next.value != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Wallet connected! Address: ${next.value!.address.substring(0, 6)}...'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wallet connection failed: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Wallet Icon
              Image.asset(
                'assets/images/shield.png',
              ),
              const SizedBox(height: 32),

              const Text(
                'Setup Your Wallet',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Nimbus will create a secure wallet for you. Your private keys are encrypted and stored safely on your device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),

              const SizedBox(height: 24),

              // Supported Wallets
              const Text(
                'Supported Wallets:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWalletIcon('MetaMask'),
                  const SizedBox(width: 16),
                  _buildWalletIcon('Trust Wallet'),
                  const SizedBox(width: 16),
                  _buildWalletIcon('Rainbow'),
                  const SizedBox(width: 16),
                  _buildWalletIcon('Coinbase'),
                ],
              ),

              //const SizedBox(height: 48),
              Spacer(
                flex: 1,
              ),

              // Connect Wallet Button
              Consumer(
                builder: (context, ref, child) {
                  final walletState = ref.watch(walletStateProvider);
                  final isLoading = walletState.isLoading;
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _connectWallet,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create Wallet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),

              // Skip for now button
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen()),
                  );
                },
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletIcon(String walletName) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Color(0xFF666666),
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          walletName,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
