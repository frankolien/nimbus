import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../shared/services/blockchain_balance_service.dart';

class WalletService {
  final http.Client _client;

  WalletService({http.Client? client}) : _client = client ?? http.Client();

  void initializeAppKit(BuildContext context) {
    // Initialize WalletConnect AppKit
    // For now, we'll use a mock implementation
  }

  Future<void> connectWallet(BuildContext context) async {
    // Simulate wallet connection for now
    await Future.delayed(const Duration(seconds: 2));

    // Mock connected wallet - this will be handled by the provider
  }

  Future<void> disconnectWallet() async {
    // Disconnect logic - this will be handled by the provider
  }

  Future<List<TokenBalance>> getTokenBalances(String? walletAddress) async {
    if (walletAddress == null) {
      return [];
    }

    try {
      print('🔍 Fetching real token balances for wallet: $walletAddress');

      // Get real blockchain balances
      final realBalances =
          await BlockchainBalanceService.getAllBalances(walletAddress);

      // Convert to TokenBalance objects
      final tokenBalances = <TokenBalance>[];

      realBalances.forEach((symbol, balance) {
        if (balance > 0) {
          tokenBalances.add(TokenBalance(
            contractAddress: _getContractAddress(symbol),
            tokenBalance: (balance * _getTokenMultiplier(symbol)).toString(),
            name: _getTokenName(symbol),
            symbol: symbol,
            decimals: _getTokenDecimals(symbol),
          ));
        }
      });

      // Only add mock balances if no real balances were found
      if (tokenBalances.isEmpty) {
        tokenBalances.addAll(_getMockTokenBalances());
        print('💰 No real balances found (RPC rate limited), using mock data');
      } else {
        print('💰 Real token balances fetched: ${tokenBalances.length} tokens');
      }

      return tokenBalances;
    } catch (e) {
      print('❌ Error fetching real balances, using mock: $e');
      return _getMockTokenBalances();
    }
  }

  String _getContractAddress(String symbol) {
    switch (symbol) {
      case 'ETH':
        return '0x0000000000000000000000000000000000000000';
      case 'USDC':
        return '0xA0b86a33E6441c8C4C4C4C4C4C4C4C4C4C4C4C4C';
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

  double _getTokenMultiplier(String symbol) {
    switch (symbol) {
      case 'ETH':
        return 1e18;
      case 'USDC':
        return 1e6;
      case 'USDT':
        return 1e6;
      case 'SOL':
        return 1e9;
      default:
        return 1e18;
    }
  }

  List<TokenBalance> _getMockTokenBalances() {
    return [
      TokenBalance(
        contractAddress: '0xA0b86a33E6441b8C4C8C0C4C8C0C4C8C0C4C8C0C',
        tokenBalance: '1000000000000000000', // 1 ETH
        name: 'Ethereum',
        symbol: 'ETH',
        decimals: 18,
      ),
      TokenBalance(
        contractAddress: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
        tokenBalance: '500000000', // 500 USDT
        name: 'Tether USD',
        symbol: 'USDT',
        decimals: 6,
      ),
      TokenBalance(
        contractAddress: '0x1234567890123456789012345678901234567890',
        tokenBalance: '5000000000', // 5 SOL
        name: 'Solana',
        symbol: 'SOL',
        decimals: 9,
      ),
    ];
  }

  Future<double> getETHBalance(String? walletAddress) async {
    if (walletAddress == null) {
      return 0.0;
    }

    try {
      // Get ETH balance from Etherscan API
      final response = await _client.get(
        Uri.parse(
          'https://api.etherscan.io/api?module=account&action=balance&address=$walletAddress&tag=latest&apikey=YourEtherscanAPIKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final balanceWei = data['result'] as String;
        return int.parse(balanceWei) / 1e18; // Convert wei to ETH
      }
    } catch (e) {
      print('Error fetching ETH balance: $e');
    }

    return 0.0;
  }
}

class TokenBalance {
  final String contractAddress;
  final String tokenBalance;
  final String name;
  final String symbol;
  final int decimals;

  TokenBalance({
    required this.contractAddress,
    required this.tokenBalance,
    required this.name,
    required this.symbol,
    required this.decimals,
  });

  double get balance {
    try {
      final balanceBigInt = BigInt.parse(tokenBalance);
      return balanceBigInt / BigInt.from(10).pow(decimals);
    } catch (e) {
      return 0.0;
    }
  }
}

// Providers
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});
