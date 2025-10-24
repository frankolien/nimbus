import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/swap_quote.dart';

part 'swap_provider.g.dart';

// Swap state
@riverpod
class SwapState extends _$SwapState {
  @override
  AsyncValue<SwapQuote?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> getSwapQuote({
    required String sellToken,
    required String buyToken,
    required String sellAmount,
    required String slippagePercentage,
    required String takerAddress,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Use real swap API (1inch, Uniswap, etc.)
      throw Exception(
          'Real swap API integration required - implement 1inch or Uniswap API');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<String> executeSwap({
    required SwapQuote quote,
    required String walletAddress,
  }) async {
    try {
      // Use real swap execution with blockchain transaction service
      throw Exception(
          'Real swap execution requires blockchain transaction service integration');
    } catch (error) {
      rethrow;
    }
  }

  void clearSwap() {
    state = const AsyncValue.data(null);
  }
}

// Swap execution state
@riverpod
class SwapExecution extends _$SwapExecution {
  @override
  AsyncValue<String?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> executeSwap({
    required SwapQuote quote,
    required String walletAddress,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Use real swap execution with blockchain transaction service
      throw Exception(
          'Real swap execution requires blockchain transaction service integration');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearExecution() {
    state = const AsyncValue.data(null);
  }
}

// Swap form state
@riverpod
class SwapForm extends _$SwapForm {
  @override
  SwapFormData build() {
    return const SwapFormData();
  }

  void updateSellToken(String tokenAddress) {
    state = state.copyWith(sellToken: tokenAddress);
  }

  void updateBuyToken(String tokenAddress) {
    state = state.copyWith(buyToken: tokenAddress);
  }

  void updateSellAmount(String amount) {
    state = state.copyWith(sellAmount: amount);
  }

  void updateSlippage(String slippage) {
    state = state.copyWith(slippagePercentage: slippage);
  }

  void swapTokens() {
    final currentSellToken = state.sellToken;
    final currentBuyToken = state.buyToken;
    state = state.copyWith(
      sellToken: currentBuyToken,
      buyToken: currentSellToken,
    );
  }
}

// Swap form data
class SwapFormData {
  final String sellToken;
  final String buyToken;
  final String sellAmount;
  final String slippagePercentage;

  const SwapFormData({
    this.sellToken = '',
    this.buyToken = '',
    this.sellAmount = '',
    this.slippagePercentage = '0.5',
  });

  SwapFormData copyWith({
    String? sellToken,
    String? buyToken,
    String? sellAmount,
    String? slippagePercentage,
  }) {
    return SwapFormData(
      sellToken: sellToken ?? this.sellToken,
      buyToken: buyToken ?? this.buyToken,
      sellAmount: sellAmount ?? this.sellAmount,
      slippagePercentage: slippagePercentage ?? this.slippagePercentage,
    );
  }
}
