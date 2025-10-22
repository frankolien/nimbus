import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbus/shared/presentation/pages/main_navigation_screen.dart';
import 'package:nimbus/features/wallet/data/services/wallet_service.dart';

class WalletConnectionScreen extends ConsumerStatefulWidget {
  const WalletConnectionScreen({super.key});

  @override
  ConsumerState<WalletConnectionScreen> createState() =>
      _WalletConnectionScreenState();
}

class _WalletConnectionScreenState
    extends ConsumerState<WalletConnectionScreen> {
  bool _isConnecting = false;

  Future<void> _connectWallet() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      final walletService = ref.read(walletServiceProvider);

      // Initialize and connect to real wallet
      await walletService.connectWallet(context);

      // Wait for connection to be established
      await Future.delayed(const Duration(seconds: 2));

      // Check if wallet is connected
      final isConnected = walletService.isConnected;

      if (isConnected && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Wallet connected! Address: ${walletService.walletAddress?.substring(0, 6)}...'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        throw Exception('Wallet connection failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wallet connection failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Wallet Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 50,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Connect Your Wallet',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Connect your preferred crypto wallet to Nimbus for secure transactions and asset management.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 48),

              // Connect Wallet Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isConnecting ? null : _connectWallet,
                  child: _isConnecting
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
                          'Connect Wallet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

              const SizedBox(height: 24),

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
