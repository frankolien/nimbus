import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/receive_provider.dart';

class AmountQRScreen extends ConsumerWidget {
  const AmountQRScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiveState = ref.watch(receiveNotifierProvider);

    // Mock asset data - in real app, this would come from a service
    final assetData = _getAssetData(receiveState.selectedAsset);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Asset Logo
          _buildAssetLogo(receiveState.selectedAsset),

          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF2C2D30),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Warning Message
                _buildWarningMessage(receiveState.selectedAsset),

                const SizedBox(height: 24),

                // Address Display
                _buildAddressDisplay(assetData, context),

                const SizedBox(height: 32),

                // QR Code
                _buildQRCode(assetData, receiveState),

                const SizedBox(height: 32),

                // Balance Display
                _buildBalanceDisplay(assetData),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Share Button
          _buildShareButton(context),
        ],
      ),
    );
  }

  Widget _buildAssetLogo(String symbol) {
    return Container(
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
          _getAssetLogoUrl(symbol),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: _getAssetGradient(symbol),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _getAssetIcon(symbol),
                color: Colors.white,
                size: 30,
              ),
            );
          },
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

  Widget _buildWarningMessage(String symbol) {
    return Text(
      'Only send ${_getNetworkName(symbol)} network tokens to this address',
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }

  String _getNetworkName(String symbol) {
    switch (symbol) {
      case 'SOL':
        return 'Solana';
      case 'USDT':
        return 'Ethereum';
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

  Widget _buildAddressDisplay(
      Map<String, dynamic> asset, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            asset['address'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _copyToClipboard(asset['address'], context),
          icon: const Icon(Icons.copy, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildQRCode(Map<String, dynamic> asset, ReceiveStateData state) {
    // Create QR data with amount information
    final qrData =
        '${asset['address']}?amount=${state.requestAmount}&currency=${state.requestCurrency}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: 250.0,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBalanceDisplay(Map<String, dynamic> asset) {
    return Column(
      children: [
        Text(
          '${asset['balance']} ${asset['symbol']}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${asset['usdValue']}',
          style: const TextStyle(
            color: Color(0xFFFF6B35),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _shareRequest(context),
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text(
          'Share',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getAssetData(String symbol) {
    final assets = {
      'SOL': {
        'symbol': 'SOL',
        'name': 'Solana',
        'address':
            'Epjjihdshvhvshvhudshuhuhfuuvhuhjdjihiswhshwhsuhwswushuwwwsw',
        'balance': '249.0',
        'usdValue': '138095.24',
      },
      'USDT': {
        'symbol': 'USDT',
        'name': 'Tether',
        'address': '0x6B175474E89094C44Da98b954EedeAC495271d0F',
        'balance': '1250.0',
        'usdValue': '1250.00',
      },
      'TON': {
        'symbol': 'TON',
        'name': 'Toncoin',
        'address': 'EQD0vdSA_NedR9uvbgd9R0p4x-TNP8SF5VcRqqD_LLa0c5k5',
        'balance': '85.5',
        'usdValue': '425.75',
      },
      'ETH': {
        'symbol': 'ETH',
        'name': 'Ethereum',
        'address': '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
        'balance': '2.1',
        'usdValue': '4200.00',
      },
      'BTC': {
        'symbol': 'BTC',
        'name': 'Bitcoin',
        'address': '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
        'balance': '0.15',
        'usdValue': '4500.00',
      },
    };

    return assets[symbol] ?? assets['SOL']!;
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        backgroundColor: Color(0xFFFF6B35),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareRequest(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: Color(0xFFFF6B35),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
