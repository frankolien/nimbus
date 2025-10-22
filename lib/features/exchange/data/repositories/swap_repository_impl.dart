import '../../domain/entities/swap_quote.dart';
import '../../domain/repositories/swap_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/swap_remote_datasource.dart';

class SwapRepositoryImpl implements SwapRepository {
  final SwapRemoteDataSource _remoteDataSource;

  SwapRepositoryImpl(this._remoteDataSource);

  @override
  Future<SwapQuote> getSwapQuote({
    required String sellToken,
    required String buyToken,
    required String sellAmount,
    required String slippagePercentage,
    required String takerAddress,
  }) async {
    try {
      return await _remoteDataSource.getSwapQuote(
        sellToken: sellToken,
        buyToken: buyToken,
        sellAmount: sellAmount,
        slippagePercentage: slippagePercentage,
        takerAddress: takerAddress,
      );
    } catch (e) {
      throw SwapFailure('Failed to get swap quote: $e');
    }
  }

  @override
  Future<String> executeSwap({
    required SwapQuote quote,
    required String walletAddress,
  }) async {
    try {
      // This would typically involve signing and sending the transaction
      // For now, returning a placeholder transaction hash
      return '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    } catch (e) {
      throw SwapFailure('Failed to execute swap: $e');
    }
  }

  @override
  Future<List<String>> getSupportedTokens() async {
    try {
      return await _remoteDataSource.getSupportedTokens();
    } catch (e) {
      throw SwapFailure('Failed to get supported tokens: $e');
    }
  }

  @override
  Future<Map<String, double>> getTokenPrices(
      List<String> tokenAddresses) async {
    try {
      return await _remoteDataSource.getTokenPrices(tokenAddresses);
    } catch (e) {
      throw SwapFailure('Failed to get token prices: $e');
    }
  }
}
