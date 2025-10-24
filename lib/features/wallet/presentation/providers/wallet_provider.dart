import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/services/blockchain_balance_service.dart';
import '../../domain/entities/wallet.dart';
import '../../../../shared/entities/token.dart';
import '../../data/services/custodial_wallet_service.dart';

part 'wallet_provider.g.dart';

// Custodial wallet service provider
final custodialWalletServiceProvider = Provider<CustodialWalletService>((ref) {
  return CustodialWalletService();
});

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
      // Get custodial wallet service
      final custodialService = ref.read(custodialWalletServiceProvider);

      // For now, use a mock user ID - in production this would come from auth
      const userId = 'user_123';

      // Create or load custodial wallet
      final custodialWallet = await custodialService.getOrCreateWallet(userId);

      // Get wallet balance
      final balance = await custodialService.getWalletBalance(userId);

      // Create wallet entity
      final wallet = Wallet(
        address: custodialWallet.address,
        balance: balance,
        isConnected: true,
      );

      state = AsyncValue.data(wallet);
      print('✅ Custodial wallet connected: ${wallet.address}');
    } catch (error, stackTrace) {
      print('❌ Custodial wallet connection failed: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> disconnectWallet() async {
    try {
      // For custodial wallets, we don't actually "disconnect"
      // We just clear the local state
      state = const AsyncValue.data(null);
      print('✅ Custodial wallet disconnected');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadTokenBalances(String walletAddress) async {
    if (state.hasValue && state.value != null) {
      state = AsyncValue.loading();

      try {
        // Use real blockchain balance service
        final balances =
            await BlockchainBalanceService.getAllBalances(walletAddress);

        final tokens = <Token>[];

        balances.forEach((symbol, balance) {
          if (balance > 0) {
            tokens.add(Token(
              address: symbol == 'ETH'
                  ? '0x0000000000000000000000000000000000000000'
                  : _getTokenContractAddress(symbol),
              symbol: symbol,
              name: _getTokenName(symbol),
              balance: balance,
              decimals: symbol == 'ETH' ? 18 : 6,
              chainId: '1', // Ethereum mainnet
            ));
          }
        });

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

  String _getTokenContractAddress(String symbol) {
    switch (symbol) {
      case 'USDC':
        return '0xA0b86a33E6441c8C4C4C4C4C4C4C4C4C4C4C4C4C';
      case 'USDT':
        return '0xdAC17F958D2ee523a2206206994597C13D831ec7';
      default:
        return '0x0000000000000000000000000000000000000000';
    }
  }

  String _getTokenName(String symbol) {
    switch (symbol) {
      case 'ETH':
        return 'Ethereum';
      case 'USDC':
        return 'USD Coin';
      case 'USDT':
        return 'Tether USD';
      default:
        return symbol;
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
