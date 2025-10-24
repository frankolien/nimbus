import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/send_provider.dart';
import '../../../../shared/services/blockchain_transaction_service.dart';
import '../../../../features/wallet/presentation/providers/wallet_provider.dart';

class ConfirmationScreen extends ConsumerWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendState = ref.watch(sendNotifierProvider);
    final sendNotifier = ref.read(sendNotifierProvider.notifier);

    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Summary
                _buildTransactionSummary(sendState),

                const SizedBox(height: 24),

                // Transaction Details
                _buildTransactionDetails(sendState),

                const SizedBox(height: 24), // Extra padding at bottom
              ],
            ),
          ),
        ),

        // Fixed Action Buttons
        Container(
          padding: const EdgeInsets.all(16.0),
          child: _buildActionButtons(context, ref, sendNotifier),
        ),
      ],
    );
  }

  Widget _buildTransactionSummary(SendStateData state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          const Text(
            'Transaction Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Amount:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Text(
                '${state.amount} SOL',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'USD Value:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Text(
                '\$${state.usdAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'To:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  state.recipientAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(SendStateData state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Network Fee', '0.000005 SOL'),
          _buildDetailRow('Estimated Time', '~2 seconds'),
          _buildDetailRow('Network', 'Solana'),
          _buildDetailRow('Remaining Balance',
              '${(state.solBalance - double.tryParse(state.amount)!).toStringAsFixed(2)} SOL'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, SendNotifier notifier) {
    return Column(
      children: [
        // Send Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _executeTransaction(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Send Transaction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Back Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => notifier.previousStep(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF333333)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _executeTransaction(BuildContext context, WidgetRef ref) async {
    final sendState = ref.read(sendNotifierProvider);
    final walletState = ref.read(walletStateProvider);

    // sendState is already SendStateData type, no need to check

    if (walletState.hasError) {
      _showErrorSnackBar(context, 'Wallet error: ${walletState.error}');
      return;
    }

    if (walletState.isLoading) {
      _showErrorSnackBar(context, 'Wallet is loading');
      return;
    }

    final wallet = walletState.value;
    if (wallet == null) {
      _showErrorSnackBar(context, 'Wallet not found');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFFFF6B35)),
            SizedBox(width: 16),
            Text(
              'Sending transaction...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      // Get gas price
      final gasPrice = await BlockchainTransactionService.getGasPrice();

      Map<String, dynamic> result;

      // For now, assume ETH transaction (you can add token selection logic)
      result = await BlockchainTransactionService.sendEthTransaction(
        fromAddress: wallet.address,
        toAddress: sendState.recipientAddress,
        privateKey: '', // This needs to be retrieved from secure storage
        amountInEth: sendState.amount,
        gasPrice: gasPrice,
        gasLimit: '0x5208', // 21000 gas for ETH transfer
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        if (result['success'] == true) {
          // Show success dialog
          _showSuccessDialog(context, result);
        } else {
          _showErrorSnackBar(context, result['error'] ?? 'Transaction failed');
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(context, 'Transaction failed: $e');
      }
    }
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Transaction Sent!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${result['amount']} ${result['tokenContract'] != null ? 'tokens' : 'ETH'}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'To: ${result['to']}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Hash: ${result['txHash']}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to home
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
