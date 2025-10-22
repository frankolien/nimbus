import '../entities/swap_quote.dart';

abstract class SwapRepository {
  Future<SwapQuote> getSwapQuote({
    required String sellToken,
    required String buyToken,
    required String sellAmount,
    required String slippagePercentage,
    required String takerAddress,
  });

  Future<String> executeSwap({
    required SwapQuote quote,
    required String walletAddress,
  });

  Future<List<String>> getSupportedTokens();
  Future<Map<String, double>> getTokenPrices(List<String> tokenAddresses);
}
