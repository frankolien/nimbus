import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/withdraw_provider.dart';
import '../../../../shared/services/crypto_price_service.dart';

class WithdrawAmountInputScreen extends ConsumerStatefulWidget {
  const WithdrawAmountInputScreen({super.key});

  @override
  ConsumerState<WithdrawAmountInputScreen> createState() =>
      _WithdrawAmountInputScreenState();
}

class _WithdrawAmountInputScreenState
    extends ConsumerState<WithdrawAmountInputScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
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

            // Asset Selection
            _buildAssetSelection(withdrawState, withdrawNotifier),

            const SizedBox(height: 32),

            // Amount Input
            _buildAmountInput(withdrawState, withdrawNotifier),

            const SizedBox(height: 32),

            // Recipient Address
            _buildRecipientAddress(withdrawState, withdrawNotifier),

            const Spacer(),

            // Continue Button
            Padding(
              padding: const EdgeInsets.only(bottom: 22.0),
              child: _buildContinueButton(withdrawState, withdrawNotifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSelection(
      WithdrawStateData state, WithdrawNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                _getAssetLogoUrl(state.selectedAsset),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: _getAssetGradient(state.selectedAsset),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        _getAssetIcon(state.selectedAsset),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedAsset,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getAssetName(state.selectedAsset),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => _buildAssetSelectionModal(notifier),
            ),
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(WithdrawStateData state, WithdrawNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.start,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
              color: Colors.white54,
              fontSize: 32,
            ),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            notifier.updateAmount(value);
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              state.currency,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => _toggleCurrency(notifier),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.swap_vert,
                  color: Colors.white54,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _getCryptoEquivalent(state, ref),
          style: const TextStyle(
            color: Color(0xFFFF6B35),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientAddress(
      WithdrawStateData state, WithdrawNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipient Address',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Enter ${state.selectedAsset} address',
            hintStyle: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B35)),
            ),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            notifier.updateRecipientAddress(value);
          },
        ),
      ],
    );
  }

  Widget _buildContinueButton(
      WithdrawStateData state, WithdrawNotifier notifier) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: notifier.canProceedToConfirmation
            ? () => notifier.nextStep()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: notifier.canProceedToConfirmation
              ? const Color(0xFFFF6B35)
              : const Color(0xFF444444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAssetSelectionModal(WithdrawNotifier notifier) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Asset',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildModalAssetItem('SOL', 'Solana', notifier),
                _buildModalAssetItem('BTC', 'Bitcoin', notifier),
                _buildModalAssetItem('ETH', 'Ethereum', notifier),
                _buildModalAssetItem('USDT', 'Tether', notifier),
                _buildModalAssetItem('TON', 'Toncoin', notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalAssetItem(
      String symbol, String name, WithdrawNotifier notifier) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            _getAssetLogoUrl(symbol),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: _getAssetGradient(symbol),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    _getAssetIcon(symbol),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      title: Text(
        symbol,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        name,
        style: const TextStyle(color: Colors.white70),
      ),
      onTap: () {
        notifier.selectAsset(symbol);
        Navigator.pop(context);
      },
    );
  }

  void _toggleCurrency(WithdrawNotifier notifier) {
    final currentCurrency = notifier.state.currency;
    final newCurrency =
        currentCurrency == 'USD' ? notifier.state.selectedAsset : 'USD';
    notifier.updateCurrency(newCurrency);
  }

  String _getCryptoEquivalent(WithdrawStateData state, WidgetRef ref) {
    if (state.amount.isEmpty) return '0.00000 ${state.selectedAsset}';

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
          // Convert USD to selected crypto
          final cryptoAmount = amount / selectedAssetPrice.price;
          return '${cryptoAmount.toStringAsFixed(5)} ${state.selectedAsset}';
        } else {
          // Convert selected crypto to USD
          final usdAmount = amount * selectedAssetPrice.price;
          return '\$${usdAmount.toStringAsFixed(2)}';
        }
      },
      loading: () {
        // Show loading state with hardcoded fallback
        if (state.currency == 'USD') {
          final cryptoAmount = amount / 138.52; // Fallback SOL price
          return '${cryptoAmount.toStringAsFixed(5)} ${state.selectedAsset}';
        } else {
          final usdAmount = amount * 138.52; // Fallback SOL price
          return '\$${usdAmount.toStringAsFixed(2)}';
        }
      },
      error: (error, stackTrace) {
        // Show error state with hardcoded fallback
        if (state.currency == 'USD') {
          final cryptoAmount = amount / 138.52; // Fallback SOL price
          return '${cryptoAmount.toStringAsFixed(5)} ${state.selectedAsset}';
        } else {
          final usdAmount = amount * 138.52; // Fallback SOL price
          return '\$${usdAmount.toStringAsFixed(2)}';
        }
      },
    );
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

  String _getAssetName(String symbol) {
    final names = {
      'SOL': 'Solana',
      'USDT': 'Tether',
      'TON': 'Toncoin',
      'ETH': 'Ethereum',
      'BTC': 'Bitcoin',
    };
    return names[symbol] ?? 'Solana';
  }
}
