import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      // Get token balances from Alchemy API (free tier)
      final response = await _client.get(
        Uri.parse(
          'https://eth-mainnet.g.alchemy.com/v2/demo/getTokenBalances?address=$walletAddress',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tokens = data['result'] as List;

        return tokens.map((token) {
          return TokenBalance(
            contractAddress: token['contractAddress'],
            tokenBalance: token['tokenBalance'],
            name: token['name'] ?? 'Unknown',
            symbol: token['symbol'] ?? 'UNK',
            decimals: token['decimals'] ?? 18,
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching token balances: $e');
    }

    // Fallback to mock data if API fails
    return _getMockTokenBalances();
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
