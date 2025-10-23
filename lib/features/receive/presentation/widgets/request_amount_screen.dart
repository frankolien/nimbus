import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/receive_provider.dart';
import '../../../../shared/services/crypto_price_service.dart';

class RequestAmountScreen extends ConsumerStatefulWidget {
  const RequestAmountScreen({super.key});

  @override
  ConsumerState<RequestAmountScreen> createState() =>
      _RequestAmountScreenState();
}

class _RequestAmountScreenState extends ConsumerState<RequestAmountScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receiveState = ref.watch(receiveNotifierProvider);
    final receiveNotifier = ref.read(receiveNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Amount Display
          _buildAmountDisplay(receiveState, receiveNotifier),

          const SizedBox(height: 32),
          Divider(),
          const SizedBox(height: 32),

          // Asset Selection
          _buildAssetSelection(receiveState, receiveNotifier),

          const SizedBox(height: 32),

          // Amount Input Field
          _buildAmountInputField(receiveState, receiveNotifier),

          Spacer(),

          // Confirm Button
          Padding(
            padding: const EdgeInsets.only(bottom: 22.0),
            child: _buildConfirmButton(receiveState, receiveNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(ReceiveStateData state, ReceiveNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              state.requestAmount.isEmpty ? '0' : state.requestAmount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              state.requestCurrency,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 24,
              ),
            ),
            IconButton(
              onPressed: () => _toggleCurrency(notifier),
              icon: const Icon(
                Icons.swap_vert,
                color: Colors.white54,
                size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getCryptoEquivalent(state, ref),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetSelection(
      ReceiveStateData state, ReceiveNotifier notifier) {
    return Row(
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
        const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildAmountInputField(
      ReceiveStateData state, ReceiveNotifier notifier) {
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
            notifier.updateRequestAmount(value);
          },
        ),
        const SizedBox(height: 8),
        Text(
          state.requestCurrency,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          _getCryptoEquivalent(state, ref),
          style: const TextStyle(
            color: Color(0xFFFF6B35),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConfirmButton(ReceiveStateData state, ReceiveNotifier notifier) {
    final canProceed = notifier.canProceedToAmount;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canProceed ? () => notifier.nextStep() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canProceed ? const Color(0xFFFF6B35) : const Color(0xFF444444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Confirm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _toggleCurrency(ReceiveNotifier notifier) {
    final currentCurrency = notifier.state.requestCurrency;
    final newCurrency = currentCurrency == 'USD' ? 'SOL' : 'USD';
    notifier.updateRequestCurrency(newCurrency);
  }

  String _getCryptoEquivalent(ReceiveStateData state, WidgetRef ref) {
    if (state.requestAmount.isEmpty) return '0.00000 SOL';

    final amount = double.tryParse(state.requestAmount) ?? 0.0;

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

        if (state.requestCurrency == 'USD') {
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
        if (state.requestCurrency == 'USD') {
          final solAmount = amount / 138.52; // Fallback SOL price
          return '${solAmount.toStringAsFixed(5)} ${state.selectedAsset}';
        } else {
          final usdAmount = amount * 138.52; // Fallback SOL price
          return '\$${usdAmount.toStringAsFixed(2)}';
        }
      },
      error: (error, stackTrace) {
        // Show error state with hardcoded fallback
        if (state.requestCurrency == 'USD') {
          final solAmount = amount / 138.52; // Fallback SOL price
          return '${solAmount.toStringAsFixed(5)} ${state.selectedAsset}';
        } else {
          final usdAmount = amount * 138.52; // Fallback SOL price
          return '\$${usdAmount.toStringAsFixed(2)}';
        }
      },
    );
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

  IconData _getAssetIcon(String symbol) {
    switch (symbol) {
      case 'SOL':
        return Icons.account_balance_wallet; // Solana wallet icon
      case 'USDT':
        return Icons.attach_money; // Dollar sign for USDT
      case 'TON':
        return Icons.telegram; // Telegram icon for TON
      case 'ETH':
        return Icons.diamond; // Diamond for Ethereum
      case 'BTC':
        return Icons.currency_bitcoin; // Bitcoin icon
      default:
        return Icons.account_balance_wallet;
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
