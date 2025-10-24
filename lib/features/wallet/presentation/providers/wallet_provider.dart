import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/services/blockchain_balance_service.dart';
import '../../../../features/wallet/data/services/custodial_wallet_service.dart';
import '../../../../features/wallet/domain/entities/wallet.dart';
import '../../../../shared/entities/token.dart';

part 'wallet_provider.g.dart';

@riverpod
class WalletState extends _$WalletState {
  @override
  AsyncValue<Wallet?> build() {
    return const AsyncValue.data(null);
  }

  /// Get consistent user ID (in production, this would come from auth service)
  Future<String> _getUserId() async {
    // TODO: Implement real user ID retrieval from auth service
    // For now, use a consistent user ID so wallet persists across app restarts
    return 'user_default';
  }

  Future<void> connectWallet() async {
    state = const AsyncValue.loading();

    try {
      // Get custodial wallet service
      final custodialService = ref.read(custodialWalletServiceProvider);

      // Get real user ID from auth service
      final userId = await _getUserId();

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
        final currentWallet = state.value!;
        final updatedWallet = Wallet(
          address: currentWallet.address,
          balance: currentWallet.balance,
          isConnected: currentWallet.isConnected,
        );

        state = AsyncValue.data(updatedWallet);
        print('✅ Token balances loaded: ${tokens.length} tokens');
      } catch (error, stackTrace) {
        print('❌ Failed to load token balances: $error');
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  // Helper methods for token data
  String _getTokenContractAddress(String symbol) {
    switch (symbol) {
      case 'ETH':
        return '0x0000000000000000000000000000000000000000';
      case 'USDC':
        return '0xA0b86a33E6441b8C4C8C0C4C8C0C4C8C0C4C8C0C4C';
      case 'USDT':
        return '0xdAC17F958D2ee523a2206206994597C13D831ec7';
      case 'SOL':
        return 'So11111111111111111111111111111111111111112';
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
      case 'SOL':
        return 'Solana';
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
      // Get real token balances from blockchain
      final balances =
          await BlockchainBalanceService.getAllBalances(walletAddress);

      final tokens = <Token>[];

      balances.forEach((symbol, balance) {
        if (balance > 0) {
          tokens.add(Token(
            address: symbol == 'ETH'
                ? '0x0000000000000000000000000000000000000000'
                : _getTokenAddress(symbol),
            symbol: symbol,
            name: _getTokenName(symbol),
            balance: balance,
            decimals: _getTokenDecimals(symbol),
            chainId: '1', // Ethereum mainnet
          ));
        }
      });

      state = AsyncValue.data(tokens);
      print('✅ Token balances loaded: ${tokens.length} tokens');
    } catch (error, stackTrace) {
      print('❌ Failed to load token balances: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Helper methods for token data
  String _getTokenAddress(String symbol) {
    switch (symbol) {
      case 'ETH':
        return '0x0000000000000000000000000000000000000000';
      case 'USDC':
        return '0xA0b86a33E6441b8C4C8C0C4C8C0C4C8C0C4C8C0C4C';
      case 'USDT':
        return '0xdAC17F958D2ee523a2206206994597C13D831ec7';
      case 'SOL':
        return 'So11111111111111111111111111111111111111112';
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
      case 'SOL':
        return 'Solana';
      default:
        return symbol;
    }
  }

  int _getTokenDecimals(String symbol) {
    switch (symbol) {
      case 'ETH':
        return 18;
      case 'USDC':
        return 6;
      case 'USDT':
        return 6;
      case 'SOL':
        return 9;
      default:
        return 18;
    }
  }
}

// Wallet connection status provider
@riverpod
bool walletConnected(WalletConnectedRef ref) {
  final walletState = ref.watch(walletStateProvider);
  return walletState.hasValue && walletState.value != null;
}

// Current wallet address provider
@riverpod
String? currentWalletAddress(CurrentWalletAddressRef ref) {
  final walletState = ref.watch(walletStateProvider);
  return walletState.hasValue ? walletState.value?.address : null;
}
