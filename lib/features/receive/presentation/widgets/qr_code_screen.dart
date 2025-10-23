import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/receive_provider.dart';

class QRCodeScreen extends ConsumerWidget {
  const QRCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiveState = ref.watch(receiveNotifierProvider);
    final receiveNotifier = ref.read(receiveNotifierProvider.notifier);

    // Mock asset data - in real app, this would come from a service
    final assetData = _getAssetData(receiveState.selectedAsset);

    return Scaffold(
      //backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 23.0),
          child: Column(
            children: [
              const SizedBox(height: 4),
              // Asset Logo
              _buildAssetLogo(receiveState.selectedAsset),
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF2C2D30),
                  borderRadius: BorderRadius.circular(24),
                  //border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Column(
                  children: [
                    // Warning Message
                    _buildWarningMessage(receiveState.selectedAsset),
                    const SizedBox(height: 8),
                    // Address Display with dotted separator
                    Column(
                      children: [
                        _buildDottedLine(),
                        _buildAddressDisplay(assetData, context),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // QR Code
                    _buildQRCode(assetData),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Action Buttons
              _buildActionButtons(receiveNotifier, context),
              const SizedBox(height: 20),
            ],
          ),
        ),
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

  Widget _buildWarningMessage(String symbol) {
    return Text(
      'Only send ${_getNetworkName(symbol)} network tokens to this address',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDottedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(
          40,
          (index) => Expanded(
            child: Container(
              height: 1,
              color:
                  index.isEven ? const Color(0xFF3A3A3A) : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressDisplay(
      Map<String, dynamic> asset, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            asset['address'],
            style: const TextStyle(
              color: Color(0xFF8A8A8A),
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
            maxLines: 2,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _copyToClipboard(asset['address'], context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.content_copy,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRCode(Map<String, dynamic> asset) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: QrImageView(
        data: asset['address'],
        version: QrVersions.auto,
        size: 280.0,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ReceiveNotifier notifier, BuildContext context) {
    return Row(
      children: [
        // Request Button
        Expanded(
          child: GestureDetector(
            onTap: () => notifier.goToRequestAmount(),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: 3.14159, // 180 degrees
                      child: const Icon(
                        Icons.call_made_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Share Button
        Expanded(
          child: GestureDetector(
            onTap: () => _shareAddress(context),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.ios_share,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        backgroundColor: Color(0xFF2C2C2C),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareAddress(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: Color(0xFF2C2C2C),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
