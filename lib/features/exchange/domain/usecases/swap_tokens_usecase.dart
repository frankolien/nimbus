import '../entities/swap_quote.dart';
import '../repositories/swap_repository.dart';

class SwapTokensUseCase {
  final SwapRepository _swapRepository;

  SwapTokensUseCase(this._swapRepository);

  Future<SwapQuote> getQuote({
    required String sellToken,
    required String buyToken,
    required String sellAmount,
    required String slippagePercentage,
    required String takerAddress,
  }) async {
    return await _swapRepository.getSwapQuote(
      sellToken: sellToken,
      buyToken: buyToken,
      sellAmount: sellAmount,
      slippagePercentage: slippagePercentage,
      takerAddress: takerAddress,
    );
  }

  Future<String> executeSwap({
    required SwapQuote quote,
    required String walletAddress,
  }) async {
    return await _swapRepository.executeSwap(
      quote: quote,
      walletAddress: walletAddress,
    );
  }
}
