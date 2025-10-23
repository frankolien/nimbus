import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/withdraw_provider.dart';
import '../../../../shared/services/crypto_price_service.dart';

class WithdrawAssetSelectionScreen extends ConsumerStatefulWidget {
  const WithdrawAssetSelectionScreen({super.key});

  @override
  ConsumerState<WithdrawAssetSelectionScreen> createState() =>
      _WithdrawAssetSelectionScreenState();
}

class _WithdrawAssetSelectionScreenState
    extends ConsumerState<WithdrawAssetSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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

            // Search Bar
            _buildSearchBar(),

            const SizedBox(height: 24),

            // Primary Asset Card
            _buildPrimaryAssetCard(withdrawState, withdrawNotifier),

            const SizedBox(height: 24),

            // Asset List
            Expanded(
              child: _buildAssetList(withdrawNotifier),
            ),

            const SizedBox(height: 20),

            // Continue Button
            _buildContinueButton(withdrawState, withdrawNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search crypto',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAssetCard(
      WithdrawStateData state, WithdrawNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                _getAssetLogoUrl(state.selectedAsset),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: _getAssetGradient(state.selectedAsset),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      _getAssetIcon(state.selectedAsset),
                      color: Colors.white,
                      size: 25,
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
                  'Withdraw ${state.selectedAsset}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Send ${state.selectedAsset} to external wallet',
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
      ),
    );
  }

  Widget _buildAssetList(WithdrawNotifier notifier) {
    final cryptoPricesAsync = ref.watch(cryptoPricesRefreshProvider);

    return cryptoPricesAsync.when(
      data: (cryptoPrices) {
        final assets = cryptoPrices
            .map((price) => {
                  'symbol': price.symbol,
                  'name': _getAssetName(price.symbol),
                  'price': price.price,
                  'balance': _getMockBalance(price.symbol),
                })
            .toList();

        return ListView.builder(
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            return _buildAssetListItem(asset, notifier);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error loading assets: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildAssetListItem(
      Map<String, dynamic> asset, WithdrawNotifier notifier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                _getAssetLogoUrl(asset['symbol']),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: _getAssetGradient(asset['symbol']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        _getAssetIcon(asset['symbol']),
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
                  asset['symbol'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${asset['balance']} ${asset['symbol']}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${asset['price'].toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${(asset['balance'] * asset['price']).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              notifier.selectAsset(asset['symbol']);
              notifier.nextStep();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(
      WithdrawStateData state, WithdrawNotifier notifier) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            notifier.canProceedToAmount ? () => notifier.nextStep() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: notifier.canProceedToAmount
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

  double _getMockBalance(String symbol) {
    final balances = {
      'SOL': 2.5,
      'USDT': 1000.0,
      'TON': 50.0,
      'ETH': 0.5,
      'BTC': 0.1,
    };
    return balances[symbol] ?? 0.0;
  }
}
