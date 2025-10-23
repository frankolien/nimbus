import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/withdraw_provider.dart';
import '../../../../shared/services/crypto_price_service.dart';

class WithdrawConfirmationScreen extends ConsumerStatefulWidget {
  const WithdrawConfirmationScreen({super.key});

  @override
  ConsumerState<WithdrawConfirmationScreen> createState() =>
      _WithdrawConfirmationScreenState();
}

class _WithdrawConfirmationScreenState
    extends ConsumerState<WithdrawConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  double _slidePosition = 0.0;
  bool _isConfirming = false;
  double _slideWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final withdrawState = ref.watch(withdrawNotifierProvider);
    final withdrawNotifier = ref.read(withdrawNotifierProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Transaction Summary
            _buildTransactionSummary(withdrawState, ref),

            const SizedBox(height: 32),

            // Transaction Details
            _buildTransactionDetails(withdrawState, ref),

            const Spacer(),

            // Slide to Confirm
            Padding(
              padding: const EdgeInsets.only(bottom: 22.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _slideWidth = constraints.maxWidth;
                  return _buildSlideToConfirm(withdrawState, withdrawNotifier);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSummary(WithdrawStateData state, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          // Asset Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                _getAssetLogoUrl(state.selectedAsset),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: _getAssetGradient(state.selectedAsset),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _getAssetIcon(state.selectedAsset),
                      color: Colors.white,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Amount
          Text(
            state.amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            state.currency,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 16),

          // USD Equivalent
          Text(
            _getUsdEquivalent(state, ref),
            style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(WithdrawStateData state, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          _buildDetailRow('To', state.recipientAddress),
          const SizedBox(height: 16),
          _buildDetailRow('Network', _getNetworkName(state.selectedAsset)),
          const SizedBox(height: 16),
          _buildDetailRow('Network Fee', '0.0005 ${state.selectedAsset}'),
          const SizedBox(height: 16),
          _buildDetailRow('Total', '${state.amount} ${state.selectedAsset}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildSlideToConfirm(
      WithdrawStateData state, WithdrawNotifier notifier) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!_isConfirming) {
          setState(() {
            _slidePosition += details.delta.dx;
            _slidePosition = _slidePosition.clamp(
                0.0, _slideWidth - 60); // 60 is button width
            _slideController.value = _slidePosition / (_slideWidth - 60);
          });
        }
      },
      onPanEnd: (details) {
        if (!_isConfirming) {
          if (_slideController.value >= 0.8) {
            // 80% threshold
            _confirmWithdrawal(notifier);
          } else {
            _slideController.reverse();
            setState(() {
              _slidePosition = 0;
            });
          }
        }
      },
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    _isConfirming
                        ? 'Processing...'
                        : 'Slide to confirm withdrawal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  left: _slideAnimation.value * (_slideWidth - 60),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: _isConfirming
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF6B35)),
                            strokeWidth: 3,
                          )
                        : const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFFFF6B35),
                            size: 28,
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmWithdrawal(WithdrawNotifier notifier) async {
    setState(() {
      _isConfirming = true;
    });

    // Simulate withdrawal processing
    await Future.delayed(const Duration(seconds: 2));

    notifier.executeWithdrawal();

    if (mounted) {
      _showSuccessScreen();
    }
  }

  void _showSuccessScreen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF26A17B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Withdrawal Successful!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your transaction has been processed',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getUsdEquivalent(WithdrawStateData state, WidgetRef ref) {
    if (state.amount.isEmpty) return '\$0.00';

    final amount = double.tryParse(state.amount) ?? 0.0;

    // Get real-time crypto prices
    final cryptoPricesAsync = ref.watch(cryptoPricesRefreshProvider);

    return cryptoPricesAsync.when(
      data: (cryptoPrices) {
        // Find the price for the selected asset
        final selectedAssetPrice = cryptoPrices.firstWhere(
          (price) =>
              price.symbol.toUpperCase() == state.selectedAsset.toUpperCase(),
          orElse: () =>
              cryptoPrices.first, // Fallback to first price if not found
        );

        if (state.currency == 'USD') {
          return '\$${amount.toStringAsFixed(2)}';
        } else {
          // Convert selected crypto to USD
          final usdAmount = amount * selectedAssetPrice.price;
          return '\$${usdAmount.toStringAsFixed(2)}';
        }
      },
      loading: () {
        // Show loading state with hardcoded fallback
        if (state.currency == 'USD') {
          return '\$${amount.toStringAsFixed(2)}';
        } else {
          final usdAmount = amount * 138.52; // Fallback SOL price
          return '\$${usdAmount.toStringAsFixed(2)}';
        }
      },
      error: (error, stackTrace) {
        // Show error state with hardcoded fallback
        if (state.currency == 'USD') {
          return '\$${amount.toStringAsFixed(2)}';
        } else {
          final usdAmount = amount * 138.52; // Fallback SOL price
          return '\$${usdAmount.toStringAsFixed(2)}';
        }
      },
    );
  }

  String _getNetworkName(String symbol) {
    switch (symbol) {
      case 'SOL':
        return 'Solana';
      case 'USDT':
        return 'Tron';
      case 'TON':
        return 'TON';
      case 'ETH':
        return 'Ethereum';
      case 'BTC':
        return 'Bitcoin';
      default:
        return 'Solana';
    }
  }

  String _getAssetLogoUrl(String symbol) {
    switch (symbol) {
      case 'SOL':
        return 'https://cryptologos.cc/logos/solana-sol-logo.png';
      case 'USDT':
        return 'https://cryptologos.cc/logos/tether-usdt-logo.png';
      case 'TON':
        return 'https://cryptologos.cc/logos/toncoin-ton-logo.png';
      case 'ETH':
        return 'https://cryptologos.cc/logos/ethereum-eth-logo.png';
      case 'BTC':
        return 'https://cryptologos.cc/logos/bitcoin-btc-logo.png';
      default:
        return 'https://cryptologos.cc/logos/solana-sol-logo.png';
    }
  }

  LinearGradient _getAssetGradient(String symbol) {
    switch (symbol) {
      case 'SOL':
        return const LinearGradient(
          colors: [Color(0xFF9945FF), Color(0xFF14F195)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'USDT':
        return const LinearGradient(
          colors: [Color(0xFF26A17B), Color(0xFF26A17B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'TON':
        return const LinearGradient(
          colors: [Color(0xFF0088CC), Color(0xFF0088CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'ETH':
        return const LinearGradient(
          colors: [Color(0xFF627EEA), Color(0xFF627EEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'BTC':
        return const LinearGradient(
          colors: [Color(0xFFF7931A), Color(0xFFF7931A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF9945FF), Color(0xFF14F195)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getAssetIcon(String symbol) {
    switch (symbol) {
      case 'SOL':
        return Icons.circle;
      case 'USDT':
        return Icons.attach_money;
      case 'TON':
        return Icons.send;
      case 'ETH':
        return Icons.diamond;
      case 'BTC':
        return Icons.currency_bitcoin;
      default:
        return Icons.circle;
    }
  }
}
