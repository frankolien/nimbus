import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/wallet.dart';
import '../../../../shared/entities/token.dart';

part 'wallet_provider.g.dart';

// Wallet state
@riverpod
class WalletState extends _$WalletState {
  @override
  AsyncValue<Wallet?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> connectWallet() async {
    state = const AsyncValue.loading();

    try {
      // Mock wallet connection for now
      await Future.delayed(const Duration(seconds: 1));
      final wallet = Wallet(
        address: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
        balance: 0.0, // Will be updated with real token balances
        isConnected: true,
      );
      state = AsyncValue.data(wallet);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> disconnectWallet() async {
    try {
      // Implement disconnect logic
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadTokenBalances(String walletAddress) async {
    if (state.hasValue && state.value != null) {
      state = AsyncValue.loading();

      try {
        // Mock token balances for now
        await Future.delayed(const Duration(seconds: 1));
        final tokens = [
          Token(
            address:
                '0x0000000000000000000000000000000000000000', // ETH native token
            symbol: 'ETH',
            name: 'Ethereum',
            balance: 0.0, // Real balance will be fetched from blockchain
            decimals: 18,
            chainId: '137', // Polygon chain ID
          ),
          Token(
            address: '0xA0b86a33E6441b8C4C8C0C4C0C4C0C4C0C4C0C4C',
            symbol: 'USDC',
            name: 'USD Coin',
            balance: 0.0, // Real balance will be fetched from blockchain
            decimals: 6,
            chainId: '137', // Polygon chain ID
          ),
        ];

        // Update wallet with token balances
        final updatedWallet = state.value!.copyWith(
          balance: tokens.isNotEmpty ? tokens.first.balance : 0.0,
        );

        state = AsyncValue.data(updatedWallet);
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}

// Token balances provider
@riverpod
class TokenBalances extends _$TokenBalances {
  @override
  AsyncValue<List<Token>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadBalances(String walletAddress) async {
    state = const AsyncValue.loading();

    try {
      // Mock token balances for now
      await Future.delayed(const Duration(seconds: 1));
      final tokens = [
        Token(
          address:
              '0x0000000000000000000000000000000000000000', // ETH native token
          symbol: 'ETH',
          name: 'Ethereum',
          balance: 0.0, // Real balance will be fetched from blockchain
          decimals: 18,
          chainId: '137', // Polygon chain ID
        ),
        Token(
          address: '0xA0b86a33E6441b8C4C8C0C4C0C4C0C4C0C4C0C4C',
          symbol: 'USDC',
          name: 'USD Coin',
          balance: 0.0, // Real balance will be fetched from blockchain
          decimals: 6,
          chainId: '137', // Polygon chain ID
        ),
      ];
      state = AsyncValue.data(tokens);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Wallet connection status
@riverpod
bool walletConnected(WalletConnectedRef ref) {
  final walletState = ref.watch(walletStateProvider);
  return walletState.hasValue && walletState.value != null;
}

// Current wallet address
@riverpod
String? currentWalletAddress(CurrentWalletAddressRef ref) {
  final walletState = ref.watch(walletStateProvider);
  return walletState.value?.address;
}
