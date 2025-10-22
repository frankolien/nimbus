import 'package:dio/dio.dart';
import '../../../../core/configs/env_config.dart';
import '../../domain/entities/swap_quote.dart';

abstract class SwapRemoteDataSource {
  Future<SwapQuote> getSwapQuote({
    required String sellToken,
    required String buyToken,
    required String sellAmount,
    required String slippagePercentage,
    required String takerAddress,
  });

  Future<List<String>> getSupportedTokens();
  Future<Map<String, double>> getTokenPrices(List<String> tokenAddresses);
}

class SwapRemoteDataSourceImpl implements SwapRemoteDataSource {
  final Dio _dio;

  SwapRemoteDataSourceImpl(this._dio);

  @override
  Future<SwapQuote> getSwapQuote({
    required String sellToken,
    required String buyToken,
    required String sellAmount,
    required String slippagePercentage,
    required String takerAddress,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.0x.org/swap/permit2/quote',
        queryParameters: {
          'sellToken': sellToken,
          'buyToken': buyToken,
          'sellAmount': sellAmount,
          'slippagePercentage': slippagePercentage,
          'taker': takerAddress,
          'chainId': '137', // Polygon chain ID
        },
        options: Options(
          headers: {
            '0x-api-key': EnvConfig.zeroXApiKey,
            '0x-version': 'v2',
          },
        ),
      );

      final data = response.data;
      return SwapQuote(
        sellToken: data['sellToken'],
        buyToken: data['buyToken'],
        sellAmount: data['sellAmount'],
        buyAmount: data['buyAmount'],
        price: data['price'],
        gasPrice: data['gasPrice'],
        gas: data['gas'],
        allowanceTarget: data['allowanceTarget'],
        to: data['to'],
        data: data['data'],
        value: data['value'],
        estimatedGas: data['estimatedGas'],
        protocolFee: data['protocolFee'],
        minimumProtocolFee: data['minimumProtocolFee'],
        buyTokenToEthRate: data['buyTokenToEthRate'],
        sellTokenToEthRate: data['sellTokenToEthRate'],
      );
    } catch (e) {
      throw Exception('Failed to get swap quote: $e');
    }
  }

  @override
  Future<List<String>> getSupportedTokens() async {
    // Note: 0x API v2 doesn't have a tokens endpoint
    // Return common Polygon tokens for now
    return [
      '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee', // ETH
      '0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270', // WMATIC
      '0x2791bca1f2de4661ed88a30c99a7a9449aa84174', // USDC
      '0xc2132d05d31c914a87c6611c10748aeb04b58e8f', // USDT
      '0x7ceb23fd6bc0add59e62ac25578270cff1b9f619', // WETH
      '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6', // WBTC
      '0x3c499c542cef5e3811e1192ce70d8cc03d5c3359', // USDC.e
    ];
  }

  @override
  Future<Map<String, double>> getTokenPrices(
      List<String> tokenAddresses) async {
    // Note: 0x API v2 price endpoint requires sellToken, buyToken, sellAmount
    // For now, return mock prices - you can integrate with CoinGecko API for real prices
    final Map<String, double> prices = {};

    for (final address in tokenAddresses) {
      switch (address.toLowerCase()) {
        case '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee': // ETH
          prices[address] = 2000.0;
          break;
        case '0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270': // WMATIC
          prices[address] = 0.8;
          break;
        case '0x2791bca1f2de4661ed88a30c99a7a9449aa84174': // USDC
          prices[address] = 1.0;
          break;
        case '0xc2132d05d31c914a87c6611c10748aeb04b58e8f': // USDT
          prices[address] = 1.0;
          break;
        case '0x7ceb23fd6bc0add59e62ac25578270cff1b9f619': // WETH
          prices[address] = 2000.0;
          break;
        case '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6': // WBTC
          prices[address] = 45000.0;
          break;
        case '0x3c499c542cef5e3811e1192ce70d8cc03d5c3359': // USDC.e
          prices[address] = 1.0;
          break;
        default:
          prices[address] = 1.0; // Default price
      }
    }

    return prices;
  }
}
