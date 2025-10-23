import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/crypto_asset.dart';
import '../providers/payment_provider_provider.dart';
import '../../data/services/payment_provider_service.dart';
import '../../../../features/wallet/presentation/providers/wallet_provider.dart';

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
  void initState() {
    super.initState();
    // Refresh payment providers when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProviderNotifier.notifier).refreshProviders();
    });
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.read(paymentProviderNotifier.notifier).refreshProviders();
            },
          ),
        ],
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
            child: Consumer(
              builder: (context, ref, child) {
                final paymentState = ref.watch(paymentProviderNotifier);

                if (paymentState.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

                if (paymentState.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading payment providers',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          paymentState.error!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(paymentProviderNotifier.notifier)
                                .refreshProviders();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(paymentProviderNotifier.notifier)
                        .refreshProviders();
                  },
                  color: const Color(0xFFFF6B35),
                  backgroundColor: const Color(0xFF1A1A1A),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: paymentState.providers.length,
                    itemBuilder: (context, index) {
                      final provider = paymentState.providers[index];
                      final status = paymentState.providerStatus[provider.name];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPaymentProviderTile(
                          provider: provider,
                          status: status,
                          onTap: () => _selectPaymentMethod(provider),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProviderTile({
    required PaymentProvider provider,
    Map<String, dynamic>? status,
    required VoidCallback onTap,
  }) {
    final isOnline = status?['isOnline'] ?? true;
    final responseTime = status?['responseTime'] ?? 'N/A';

    return GestureDetector(
      onTap: provider.isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: provider.isAvailable
              ? const Color(0xFF1A1A1A)
              : const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: provider.isAvailable
                ? const Color(0xFF333333)
                : const Color(0xFF222222),
          ),
        ),
        child: Row(
          children: [
            // Provider Logo
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                children: [
                  provider.logoUrl.startsWith('assets/')
                      ? Image.asset(
                          provider.logoUrl,
                          fit: BoxFit.contain,
                        )
                      : Image.network(
                          provider.logoUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF444444),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
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
                  // Online status indicator
                  if (isOnline)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Provider Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        provider.name,
                        style: TextStyle(
                          color: provider.isAvailable
                              ? Colors.white
                              : Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (provider.name == 'MoonPay') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B46C1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'New? No fees!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      if (provider.name == 'Binance') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3BA2F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'World\'s #1',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (!provider.isAvailable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Unavailable',
                            style: TextStyle(
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
                    provider.description,
                    style: TextStyle(
                      color: provider.isAvailable
                          ? Colors.white70
                          : Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Fees: ${provider.fees}',
                        style: TextStyle(
                          color: provider.isAvailable
                              ? Colors.white60
                              : Colors.white30,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Min: \$${provider.minAmount.toInt()}',
                        style: TextStyle(
                          color: provider.isAvailable
                              ? Colors.white60
                              : Colors.white30,
                          fontSize: 12,
                        ),
                      ),
                      if (isOnline) ...[
                        const SizedBox(width: 16),
                        Text(
                          responseTime,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: provider.isAvailable ? Colors.white70 : Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _selectPaymentMethod(PaymentProvider provider) async {
    if (!provider.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${provider.name} is currently unavailable'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      HapticFeedback.lightImpact();

      // Get wallet address
      final walletState = ref.read(walletStateProvider);
      String? walletAddress;

      walletState.when(
        data: (wallet) => walletAddress = wallet?.address,
        loading: () => walletAddress = null,
        error: (_, __) => walletAddress = null,
      );

      if (walletAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet not connected'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Calculate crypto amount (simplified calculation)
      final cryptoAmount = (double.tryParse(widget.usdAmount) ?? 0) /
          190.0; // Assuming SOL price ~$190

      // Launch payment provider
      final success = await PaymentProviderService.launchPaymentProvider(
        context: context,
        providerName: provider.name,
        cryptoAsset: widget.selectedAsset.symbol,
        cryptoAmount: cryptoAmount.toStringAsFixed(6),
        fiatAmount: widget.usdAmount,
        fiatCurrency: 'USD',
        walletAddress: walletAddress!,
      );

      if (success) {
        // Show additional info about the payment process
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redirecting to ${provider.name} for payment...'),
            backgroundColor: const Color(0xFF2C2C2E),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View Details',
              textColor: Colors.white,
              onPressed: () {
                _showPaymentDetails(provider);
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showPaymentDetails(PaymentProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${provider.name} Payment Details',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Fees', provider.fees),
            _buildDetailRow('Min Amount', '\$${provider.minAmount.toInt()}'),
            _buildDetailRow('Max Amount', '\$${provider.maxAmount.toInt()}'),
            _buildDetailRow('Processing Time', provider.processingTime),
            _buildDetailRow(
                'Supported Crypto', provider.supportedCrypto.join(', ')),
            _buildDetailRow(
                'Supported Fiat', provider.supportedCurrencies.join(', ')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _selectPaymentMethod(provider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue with ${provider.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
