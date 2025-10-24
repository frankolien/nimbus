import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:nimbus/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:nimbus/shared/services/blockchain_balance_service.dart';
import '../../core/configs/api_keys.dart';

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

  CryptoPriceService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<CryptoPrice>> getCryptoPrices(String? walletAddress) async {
    try {
      print('Fetching crypto prices...');

      // Get real wallet balances
      final walletBalances = await _getWalletBalances(walletAddress);

      // Try to fetch from CoinGecko API first
      try {
        final apiKey = ApiKeys.coinGeckoApiKey.isNotEmpty &&
                ApiKeys.coinGeckoApiKey != 'your_coingecko_api_key_here'
            ? '&x_cg_demo_api_key=${ApiKeys.coinGeckoApiKey}'
            : '';

        final url =
            'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana,tether,toncoin&vs_currencies=usd&include_24hr_change=true$apiKey';
        print('🔍 Fetching from CoinGecko: $url');

        final response = await _client.get(Uri.parse(url));

        print('📡 CoinGecko response status: ${response.statusCode}');
        print(
            '📡 CoinGecko response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('✅ CoinGecko data received successfully');
          return _parseCoinGeckoData(data, walletBalances);
        } else {
          print(
              '❌ CoinGecko API error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('❌ CoinGecko API failed: $e');
      }

      // Try free CoinGecko API without API key as fallback
      try {
        final freeUrl =
            'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana,tether,toncoin&vs_currencies=usd&include_24hr_change=true';
        print('🔄 Trying free CoinGecko API: $freeUrl');

        final response = await _client.get(Uri.parse(freeUrl));

        print('📡 Free CoinGecko response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('✅ Free CoinGecko data received successfully');
          return _parseCoinGeckoData(data, walletBalances);
        } else {
          print(
              '❌ Free CoinGecko API error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('❌ Free CoinGecko API failed: $e');
      }

      // If all APIs fail, throw an error instead of using mock data
      throw Exception('Failed to fetch crypto prices from all sources');
    } catch (e) {
      print('Error fetching crypto prices: $e');
      throw Exception('Failed to fetch crypto prices: $e');
    }
  }

  List<CryptoPrice> _parseCoinGeckoData(
      Map<String, dynamic> data, Map<String, double> walletBalances) {
    final cryptoData = [
      {
        'id': 'bitcoin',
        'symbol': 'BTC',
        'name': 'Bitcoin',
        'image': 'https://assets.coingecko.com/coins/images/1/small/bitcoin.png'
      },
      {
        'id': 'ethereum',
        'symbol': 'ETH',
        'name': 'Ethereum',
        'image':
            'https://assets.coingecko.com/coins/images/279/small/ethereum.png'
      },
      {
        'id': 'solana',
        'symbol': 'SOL',
        'name': 'Solana',
        'image':
            'https://assets.coingecko.com/coins/images/4128/small/solana.png'
      },
      {
        'id': 'tether',
        'symbol': 'USDT',
        'name': 'Tether',
        'image':
            'https://assets.coingecko.com/coins/images/325/small/Tether.png'
      },
      {
        'id': 'toncoin',
        'symbol': 'TON',
        'name': 'Toncoin',
        'image':
            'https://assets.coingecko.com/coins/images/17980/small/ton_symbol.png'
      },
    ];

    List<CryptoPrice> cryptoPrices = [];

    for (var crypto in cryptoData) {
      final id = crypto['id'] as String;
      final symbol = crypto['symbol'] as String;
      final name = crypto['name'] as String;
      final imageUrl = crypto['image'] as String;

      if (data.containsKey(id)) {
        final cryptoInfo = data[id] as Map<String, dynamic>;
        final price = (cryptoInfo['usd'] as num).toDouble();
        final change24h =
            (cryptoInfo['usd_24h_change'] as num?)?.toDouble() ?? 0.0;
        final balance = walletBalances[symbol] ?? 0.0;

        cryptoPrices.add(CryptoPrice(
          symbol: symbol,
          name: name,
          price: price,
          change24h: change24h,
          imageUrl: imageUrl,
          balance: balance,
          balanceValue: balance * price,
        ));

        print(
            'Fetched ${symbol}: \$${price.toStringAsFixed(2)} (${change24h >= 0 ? '+' : ''}${change24h.toStringAsFixed(2)}%)');
      }
    }

    return cryptoPrices;
  }

  Future<Map<String, double>> _getWalletBalances(String? walletAddress) async {
    try {
      // Get token balances from blockchain service directly
      final balances =
          await BlockchainBalanceService.getAllBalances(walletAddress!);

      Map<String, double> walletBalances = {};
      balances.forEach((symbol, balance) {
        walletBalances[symbol.toUpperCase()] = balance;
      });

      return walletBalances;
    } catch (e) {
      print('Error getting wallet balances: $e');
      return {};
    }
  }

  double getTotalBalance(List<CryptoPrice> prices) {
    return prices.fold(0.0, (sum, price) => sum + price.balanceValue);
  }
}

// Provider for crypto price service
final cryptoPriceServiceProvider = Provider<CryptoPriceService>((ref) {
  return CryptoPriceService();
});

// Provider for crypto prices with auto-refresh
final cryptoPricesProvider = FutureProvider<List<CryptoPrice>>((ref) async {
  final service = ref.watch(cryptoPriceServiceProvider);
  final walletAddress = ref.watch(currentWalletAddressProvider);
  return service.getCryptoPrices(walletAddress);
});

// Auto-refresh provider that triggers updates every 30 seconds
final cryptoPricesRefreshProvider =
    StreamProvider<List<CryptoPrice>>((ref) async* {
  final service = ref.watch(cryptoPriceServiceProvider);
  final walletAddress = ref.watch(currentWalletAddressProvider);

  while (true) {
    try {
      final prices = await service.getCryptoPrices(walletAddress);
      yield prices;
    } catch (e) {
      print('Error in crypto prices refresh: $e');
      // Yield empty list on error to keep stream alive
      yield <CryptoPrice>[];
    }

    // Wait 30 seconds before next update
    await Future.delayed(const Duration(seconds: 30));
  }
});

// Provider for total balance - uses auto-refresh provider
final totalBalanceProvider = Provider<double>((ref) {
  final prices = ref.watch(cryptoPricesRefreshProvider);
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
