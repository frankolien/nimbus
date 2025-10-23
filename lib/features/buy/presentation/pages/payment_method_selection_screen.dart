import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/crypto_asset.dart';

class PaymentMethodSelectionScreen extends ConsumerStatefulWidget {
  final String usdAmount;
  final CryptoAsset selectedAsset;

  const PaymentMethodSelectionScreen({
    super.key,
    required this.usdAmount,
    required this.selectedAsset,
  });

  @override
  ConsumerState<PaymentMethodSelectionScreen> createState() =>
      _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState
    extends ConsumerState<PaymentMethodSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Buy crypto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Choose Payment Method Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Choose payment method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Payment Methods List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildPaymentProviderTile(
                  logoAsset: 'assets/images/Banxa.png',
                  title: 'Banxa',
                  subtitle: 'Card, Google Pay or bank transfer',
                  onTap: () => _selectPaymentMethod('Banxa'),
                ),
                const SizedBox(height: 12),
                _buildPaymentProviderTile(
                  logoAsset: 'assets/images/Moonpay.png',
                  title: 'MoonPay',
                  subtitle: 'Card, Google Pay or bank transfer',
                  badge: 'New? No fees!',
                  badgeColor: const Color(0xFF6B46C1),
                  onTap: () => _selectPaymentMethod('MoonPay'),
                ),
                const SizedBox(height: 12),
                _buildPaymentProviderTile(
                  logoAsset: 'assets/images/Simplex.png',
                  title: 'Simplex',
                  subtitle: 'Card, Google Pay or Direct SEPA',
                  onTap: () => _selectPaymentMethod('Simplex'),
                ),
                const SizedBox(height: 12),
                _buildPaymentProviderTile(
                  logoAsset: 'assets/images/Coinbase.png',
                  title: 'Coinbase',
                  subtitle: 'Card, Google Pay or bank transfer',
                  onTap: () => _selectPaymentMethod('Coinbase'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProviderTile({
    required String logoAsset,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    print('Loading asset: $logoAsset');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Image.asset(
                logoAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading asset: $logoAsset, Error: $error');
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF444444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.payment,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor ?? const Color(0xFF6B46C1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _selectPaymentMethod(String method) {
    // TODO: Implement payment method selection logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $method'),
        backgroundColor: const Color(0xFFFF6B35),
      ),
    );
  }
}
