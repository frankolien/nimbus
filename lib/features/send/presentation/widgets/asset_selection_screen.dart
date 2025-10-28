import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../providers/send_provider.dart';

class AssetSelectionScreen extends ConsumerStatefulWidget {
  const AssetSelectionScreen({super.key});

  @override
  ConsumerState<AssetSelectionScreen> createState() =>
      _AssetSelectionScreenState();
}

class _AssetSelectionScreenState extends ConsumerState<AssetSelectionScreen> {
  List<Map<String, dynamic>> get _cryptoAssets {
    final sendState = ref.watch(sendNotifierProvider);
    final balances = sendState.realBalances ?? {};

    return [
      {
        'symbol': 'SOL',
        'name': 'Solana',
        'icon': '🟣',
        'balance': balances['SOL'] ?? 0.0,
      },
      {
        'symbol': 'USDT',
        'name': 'Tether',
        'icon': '🟢',
        'balance': balances['USDT'] ?? 0.0,
      },
      {
        'symbol': 'ETH',
        'name': 'Ethereum',
        'icon': '⚪',
        'balance': balances['ETH'] ?? 0.0,
      },
      {
        'symbol': 'BTC',
        'name': 'Bitcoin',
        'icon': '🟠',
        'balance': balances['BTC'] ?? 0.0,
      },
      {
        'symbol': 'TON',
        'name': 'Toncoin',
        'icon': '🔵',
        'balance': balances['TON'] ?? 0.0,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sendNotifier = ref.read(sendNotifierProvider.notifier);
    final sendState = ref.watch(sendNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Text
          _buildInfoText(),

          const SizedBox(height: 24),

          // Crypto Assets List
          _buildCryptoAssetsList(sendNotifier, sendState),
        ],
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFFFF6B35),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select the cryptocurrency you want to send',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoAssetsList(SendNotifier notifier, SendStateData state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._cryptoAssets.map(
          (asset) => _buildAssetListItem(asset, notifier, state),
        ),
      ],
    );
  }

  Widget _buildAssetListItem(
      Map<String, dynamic> asset, SendNotifier notifier, SendStateData state) {
    final isSelected = state.selectedAsset == asset['symbol'];

    final hasBalance = (asset['balance'] as double) > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: hasBalance ? const Color(0xFF1A1A1A) : const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFFF6B35)
              : (hasBalance
                  ? const Color(0xFF333333)
                  : const Color(0xFF222222)),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasBalance
              ? () {
                  print(
                      'Tapping asset: ${asset['symbol']} with balance: ${asset['balance']}');
                  notifier.selectAsset(asset['symbol'] as String);
                  notifier.nextStep();
                }
              : () {
                  print('Asset ${asset['symbol']} has no balance');
                },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      _getAssetLogoUrl(asset['symbol']),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: _getAssetGradient(asset['symbol']),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Icon(
                              _getAssetIcon(asset['symbol']),
                              color: Colors.white,
                              size: 24,
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
                        asset['name'],
                        style: TextStyle(
                          color: hasBalance ? Colors.white : Colors.white38,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasBalance
                            ? '${asset['balance']} ${asset['symbol']}'
                            : 'No balance',
                        style: TextStyle(
                          color: hasBalance ? Colors.white70 : Colors.white24,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
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
        return Icons.account_balance_wallet;
      case 'USDT':
        return Icons.attach_money;
      case 'TON':
        return Icons.telegram;
      case 'ETH':
        return Icons.diamond;
      case 'BTC':
        return Icons.currency_bitcoin;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
