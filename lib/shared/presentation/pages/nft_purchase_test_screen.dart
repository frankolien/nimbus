import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/nft_service.dart';

class NFTPurchaseTestScreen extends ConsumerWidget {
  const NFTPurchaseTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('NFT Purchase Test'),
        backgroundColor: const Color(0xFF2C2C2E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test NFT Purchase',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _testPurchase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Test Purchase'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testPurchase(BuildContext context) async {
    print('🧪 Starting test purchase...');

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
      ),
    );

    try {
      print('💳 Calling NFTService.purchaseNFT directly...');

      final result = await NFTService.purchaseNFT(
        contractAddress: '0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D',
        tokenId: '1234',
        price: 1.5,
        buyerAddress: '0xd3b457c239a5594860cfa9c3a376890b3e4724a4',
        privateKey:
            '0x1b9a64fa8c4c8b8e8f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e',
      );

      print('✅ Test purchase result: $result');

      if (context.mounted) Navigator.pop(context); // Close loading

      if (result['success'] == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Test purchase successful! TX: ${result['transactionHash']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception(result['error'] ?? 'Test purchase failed');
      }
    } catch (e) {
      print('❌ Test purchase error: $e');
      if (context.mounted) Navigator.pop(context); // Close loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test purchase failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
