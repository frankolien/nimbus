import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'purchase_tracking_service.dart';

class PaymentProviderService {
  static const Map<String, PaymentProvider> _providers = {
    'Banxa': PaymentProvider(
      name: 'Banxa',
      logoUrl: 'assets/images/Banxa.png',
      website: 'https://banxa.com',
      apiUrl: 'https://banxa.com/api',
      description: 'Card, Google Pay or bank transfer',
      supportedCurrencies: ['USD', 'EUR', 'GBP', 'CAD', 'AUD'],
      supportedCrypto: ['BTC', 'ETH', 'SOL', 'USDC', 'USDT'],
      fees: '2.5% - 4.5%',
      minAmount: 50,
      maxAmount: 10000,
      processingTime: '1-3 minutes',
      isAvailable: true,
    ),
    'MoonPay': PaymentProvider(
      name: 'MoonPay',
      logoUrl: 'assets/images/Moonpay.png',
      website: 'https://moonpay.com',
      apiUrl: 'https://api.moonpay.com',
      description: 'Card, Google Pay or bank transfer',
      supportedCurrencies: ['USD', 'EUR', 'GBP', 'CAD', 'AUD'],
      supportedCrypto: ['BTC', 'ETH', 'SOL', 'USDC', 'USDT'],
      fees: '1% - 4.5%',
      minAmount: 25,
      maxAmount: 50000,
      processingTime: '1-5 minutes',
      isAvailable: true,
    ),
    'Simplex': PaymentProvider(
      name: 'Simplex',
      logoUrl: 'assets/images/Simplex.png',
      website: 'https://simplex.com',
      apiUrl: 'https://api.simplex.com',
      description: 'Card, Google Pay or Direct SEPA',
      supportedCurrencies: ['USD', 'EUR', 'GBP', 'CAD', 'AUD'],
      supportedCrypto: ['BTC', 'ETH', 'SOL', 'USDC', 'USDT'],
      fees: '3.5% - 5%',
      minAmount: 100,
      maxAmount: 20000,
      processingTime: '5-15 minutes',
      isAvailable: true,
    ),
    'Coinbase': PaymentProvider(
      name: 'Coinbase',
      logoUrl: 'assets/images/Coinbase.png',
      website: 'https://coinbase.com',
      apiUrl: 'https://api.coinbase.com',
      description: 'Card, Google Pay or bank transfer',
      supportedCurrencies: ['USD', 'EUR', 'GBP', 'CAD', 'AUD'],
      supportedCrypto: ['BTC', 'ETH', 'SOL', 'USDC', 'USDT'],
      fees: '1.49% - 3.99%',
      minAmount: 25,
      maxAmount: 25000,
      processingTime: '1-3 minutes',
      isAvailable: true,
    ),
    'Binance': PaymentProvider(
      name: 'Binance',
      logoUrl: 'https://cryptologos.cc/logos/binance-coin-bnb-logo.png',
      website: 'https://binance.com',
      apiUrl: 'https://api.binance.com',
      description: 'Card, bank transfer, P2P trading',
      supportedCurrencies: ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'NGN'],
      supportedCrypto: [
        'BTC',
        'ETH',
        'SOL',
        'USDC',
        'USDT',
        'BNB',
        'ADA',
        'DOT'
      ],
      fees: '0.1% - 2.5%',
      minAmount: 10,
      maxAmount: 100000,
      processingTime: 'Instant - 5 minutes',
      isAvailable: true,
    ),
  };

  static List<PaymentProvider> getAllProviders() {
    return _providers.values.toList();
  }

  static PaymentProvider? getProvider(String name) {
    return _providers[name];
  }

  static Future<bool> launchPaymentProvider({
    required BuildContext context,
    required String providerName,
    required String cryptoAsset,
    required String cryptoAmount,
    required String fiatAmount,
    required String fiatCurrency,
    required String walletAddress,
  }) async {
    try {
      final provider = _providers[providerName];
      if (provider == null) {
        throw Exception('Payment provider not found: $providerName');
      }

      if (!provider.isAvailable) {
        throw Exception(
            'Payment provider is currently unavailable: $providerName');
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );

      // Generate payment URL based on provider
      final paymentUrl = _generatePaymentUrl(
        provider: provider,
        cryptoAsset: cryptoAsset,
        cryptoAmount: cryptoAmount,
        fiatAmount: fiatAmount,
        fiatCurrency: fiatCurrency,
        walletAddress: walletAddress,
      );

      // Launch the payment provider URL
      final Uri url = Uri.parse(paymentUrl);
      if (await canLaunchUrl(url)) {
        // Track the pending purchase
        await PurchaseTrackingService.trackPendingPurchase(
          providerName: provider.name,
          cryptoAsset: cryptoAsset,
          cryptoAmount: cryptoAmount,
          fiatAmount: fiatAmount,
          fiatCurrency: fiatCurrency,
          walletAddress: walletAddress,
          purchaseUrl: paymentUrl,
        );

        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        // Close loading dialog
        if (context.mounted) Navigator.pop(context);

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${provider.name} payment page...'),
              backgroundColor: const Color(0xFF2C2C2E),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        return true;
      } else {
        // Close loading dialog
        if (context.mounted) Navigator.pop(context);

        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open ${provider.name}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        return false;
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) Navigator.pop(context);

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening payment provider: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return false;
    }
  }

  static String _generatePaymentUrl({
    required PaymentProvider provider,
    required String cryptoAsset,
    required String cryptoAmount,
    required String fiatAmount,
    required String fiatCurrency,
    required String walletAddress,
  }) {
    // This is a simplified URL generation
    // In a real implementation, you would use the provider's actual API
    // to generate proper payment URLs with authentication, signatures, etc.

    switch (provider.name) {
      case 'Banxa':
        return '${provider.website}/buy?crypto=$cryptoAsset&amount=$cryptoAmount&fiat=$fiatCurrency&wallet=$walletAddress';
      case 'MoonPay':
        return '${provider.website}/buy?cryptoCurrency=$cryptoAsset&baseCurrencyAmount=$fiatAmount&baseCurrencyCode=$fiatCurrency&walletAddress=$walletAddress';
      case 'Simplex':
        return '${provider.website}/buy?crypto=$cryptoAsset&amount=$cryptoAmount&currency=$fiatCurrency&address=$walletAddress';
      case 'Coinbase':
        return '${provider.website}/buy?crypto=$cryptoAsset&amount=$cryptoAmount&currency=$fiatCurrency&wallet=$walletAddress';
      case 'Binance':
        return '${provider.website}/buy-crypto?crypto=$cryptoAsset&amount=$cryptoAmount&fiat=$fiatCurrency&walletAddress=$walletAddress';
      default:
        return provider.website;
    }
  }

  static Future<Map<String, dynamic>> getProviderStatus(
      String providerName) async {
    // Mock real-time status check
    // In a real implementation, this would ping the provider's API
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'isOnline': true,
      'responseTime':
          '${(50 + (DateTime.now().millisecondsSinceEpoch % 200))}ms',
      'lastChecked': DateTime.now().toIso8601String(),
      'errorRate': '0.1%',
    };
  }

  static Future<List<PaymentProvider>> getAvailableProviders() async {
    // Mock real-time availability check
    await Future.delayed(const Duration(milliseconds: 300));

    return _providers.values.where((provider) => provider.isAvailable).toList();
  }
}

class PaymentProvider {
  final String name;
  final String logoUrl;
  final String website;
  final String apiUrl;
  final String description;
  final List<String> supportedCurrencies;
  final List<String> supportedCrypto;
  final String fees;
  final double minAmount;
  final double maxAmount;
  final String processingTime;
  final bool isAvailable;

  const PaymentProvider({
    required this.name,
    required this.logoUrl,
    required this.website,
    required this.apiUrl,
    required this.description,
    required this.supportedCurrencies,
    required this.supportedCrypto,
    required this.fees,
    required this.minAmount,
    required this.maxAmount,
    required this.processingTime,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'website': website,
      'apiUrl': apiUrl,
      'description': description,
      'supportedCurrencies': supportedCurrencies,
      'supportedCrypto': supportedCrypto,
      'fees': fees,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'processingTime': processingTime,
      'isAvailable': isAvailable,
    };
  }

  factory PaymentProvider.fromJson(Map<String, dynamic> json) {
    return PaymentProvider(
      name: json['name'],
      logoUrl: json['logoUrl'],
      website: json['website'],
      apiUrl: json['apiUrl'],
      description: json['description'],
      supportedCurrencies: List<String>.from(json['supportedCurrencies']),
      supportedCrypto: List<String>.from(json['supportedCrypto']),
      fees: json['fees'],
      minAmount: json['minAmount'],
      maxAmount: json['maxAmount'],
      processingTime: json['processingTime'],
      isAvailable: json['isAvailable'],
    );
  }
}
