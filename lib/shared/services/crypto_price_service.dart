import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:nimbus/features/wallet/data/services/wallet_service.dart';

class CryptoPrice {
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final String imageUrl;
  final double balance;
  final double balanceValue;

  CryptoPrice({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change24h,
    required this.imageUrl,
    required this.balance,
    required this.balanceValue,
  });
}

class CryptoPriceService {
  final http.Client _client;
  final Ref _ref;
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  CryptoPriceService(this._ref, {http.Client? client})
      : _client = client ?? http.Client();

  Future<List<CryptoPrice>> getCryptoPrices() async {
    try {
      // Get prices for major cryptocurrencies
      final response = await _client.get(
        Uri.parse(
            '$_baseUrl/simple/price?ids=bitcoin,ethereum,solana,tether,toncoin&vs_currencies=usd&include_24hr_change=true'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Get real wallet balances
        final walletBalances = await _getWalletBalances();

        return [
          CryptoPrice(
            symbol: 'USDT',
            name: 'Tether',
            price: data['tether']['usd'].toDouble(),
            change24h: data['tether']['usd_24h_change'].toDouble(),
            imageUrl:
                'https://assets.coingecko.com/coins/images/325/small/Tether.png',
            balance: walletBalances['USDT'] ?? 0.0,
            balanceValue: (walletBalances['USDT'] ?? 0.0) *
                data['tether']['usd'].toDouble(),
          ),
          CryptoPrice(
            symbol: 'SOL',
            name: 'Solana',
            price: data['solana']['usd'].toDouble(),
            change24h: data['solana']['usd_24h_change'].toDouble(),
            imageUrl:
                'https://assets.coingecko.com/coins/images/4128/small/solana.png',
            balance: walletBalances['SOL'] ?? 0.0,
            balanceValue: (walletBalances['SOL'] ?? 0.0) *
                data['solana']['usd'].toDouble(),
          ),
          CryptoPrice(
            symbol: 'TON',
            name: 'Ton',
            price: data['toncoin']['usd'].toDouble(),
            change24h: data['toncoin']['usd_24h_change'].toDouble(),
            imageUrl:
                'https://assets.coingecko.com/coins/images/17980/small/ton_symbol.png',
            balance: walletBalances['TON'] ?? 0.0,
            balanceValue: (walletBalances['TON'] ?? 0.0) *
                data['toncoin']['usd'].toDouble(),
          ),
          CryptoPrice(
            symbol: 'ETH',
            name: 'Ethereum',
            price: data['ethereum']['usd'].toDouble(),
            change24h: data['ethereum']['usd_24h_change'].toDouble(),
            imageUrl:
                'https://assets.coingecko.com/coins/images/279/small/ethereum.png',
            balance: walletBalances['ETH'] ?? 0.0,
            balanceValue: (walletBalances['ETH'] ?? 0.0) *
                data['ethereum']['usd'].toDouble(),
          ),
          CryptoPrice(
            symbol: 'BTC',
            name: 'Bitcoin',
            price: data['bitcoin']['usd'].toDouble(),
            change24h: data['bitcoin']['usd_24h_change'].toDouble(),
            imageUrl:
                'https://assets.coingecko.com/coins/images/1/small/bitcoin.png',
            balance: walletBalances['BTC'] ?? 0.0,
            balanceValue: (walletBalances['BTC'] ?? 0.0) *
                data['bitcoin']['usd'].toDouble(),
          ),
        ];
      } else {
        throw Exception('Failed to load crypto prices');
      }
    } catch (e) {
      // Return mock data if API fails
      return _getMockCryptoPrices();
    }
  }

  Future<Map<String, double>> _getWalletBalances() async {
    try {
      // Get token balances from wallet service
      final walletService = _ref.read(walletServiceProvider);
      final tokenBalances = await walletService.getTokenBalances();

      Map<String, double> balances = {};
      for (var token in tokenBalances) {
        balances[token.symbol.toUpperCase()] = token.balance;
      }

      return balances;
    } catch (e) {
      print('Error getting wallet balances: $e');
      return {};
    }
  }

  List<CryptoPrice> _getMockCryptoPrices() {
    return [
      CryptoPrice(
        symbol: 'USDT',
        name: 'Tether',
        price: 0.99,
        change24h: 0.001,
        imageUrl:
            'https://assets.coingecko.com/coins/images/325/small/Tether.png',
        balance: 0.0,
        balanceValue: 0.0,
      ),
      CryptoPrice(
        symbol: 'SOL',
        name: 'Solana',
        price: 146.76,
        change24h: -6.2,
        imageUrl:
            'https://assets.coingecko.com/coins/images/4128/small/solana.png',
        balance: 0.0,
        balanceValue: 0.0,
      ),
      CryptoPrice(
        symbol: 'TON',
        name: 'Ton',
        price: 146.76,
        change24h: -4.01,
        imageUrl:
            'https://assets.coingecko.com/coins/images/17980/small/ton_symbol.png',
        balance: 0.0,
        balanceValue: 0.0,
      ),
      CryptoPrice(
        symbol: 'ETH',
        name: 'Ethereum',
        price: 2401.89,
        change24h: 4.01,
        imageUrl:
            'https://assets.coingecko.com/coins/images/279/small/ethereum.png',
        balance: 0.0,
        balanceValue: 0.0,
      ),
      CryptoPrice(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 2401.89,
        change24h: -4.01,
        imageUrl:
            'https://assets.coingecko.com/coins/images/1/small/bitcoin.png',
        balance: 0.0,
        balanceValue: 0.0,
      ),
    ];
  }

  double getTotalBalance(List<CryptoPrice> prices) {
    return prices.fold(0.0, (sum, price) => sum + price.balanceValue);
  }
}

// Provider for crypto price service
final cryptoPriceServiceProvider = Provider<CryptoPriceService>((ref) {
  return CryptoPriceService(ref);
});

// Provider for crypto prices with auto-refresh
final cryptoPricesProvider = FutureProvider<List<CryptoPrice>>((ref) async {
  final service = ref.watch(cryptoPriceServiceProvider);

  // Auto-refresh every 30 seconds
  Timer.periodic(const Duration(seconds: 30), (timer) {
    ref.invalidateSelf();
  });

  return service.getCryptoPrices();
});

// Provider for total balance - simplified to avoid circular dependencies
final totalBalanceProvider = Provider<double>((ref) {
  final prices = ref.watch(cryptoPricesProvider);
  return prices.when(
    data: (prices) {
      double totalValue = 0.0;
      for (var price in prices) {
        totalValue += price.balanceValue;
      }
      return totalValue;
    },
    loading: () => 0.0,
    error: (error, stack) => 0.0,
  );
});
