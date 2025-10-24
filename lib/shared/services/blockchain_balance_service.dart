import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/configs/api_keys.dart';

class BlockchainBalanceService {
  // Solana RPC endpoints
  static const String _solanaMainnetRpc = 'https://api.mainnet-beta.solana.com';
  static const String _solanaTestnetRpc = 'https://api.testnet.solana.com';

  // Ethereum RPC endpoints (using API keys from config)
  static String get _ethereumMainnetRpc =>
      'https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}';
  static const String _ethereumBackupRpc = 'https://eth.llamarpc.com';
  static String get _ethereumAlchemyRpc =>
      'https://eth-mainnet.g.alchemy.com/v2/${ApiKeys.alchemyApiKey}';

  /// Get real SOL balance for a Solana wallet address
  static Future<double> getSolBalance(String walletAddress) async {
    try {
      final response = await http.post(
        Uri.parse(_solanaMainnetRpc),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getBalance',
          'params': [walletAddress]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null) {
          // Solana balance is in lamports (1 SOL = 1,000,000,000 lamports)
          final lamports = data['result']['value'] as int;
          return lamports / 1000000000.0; // Convert to SOL
        }
      }

      print('❌ Error fetching SOL balance: ${response.statusCode}');
      return 0.0;
    } catch (e) {
      print('❌ Error fetching SOL balance: $e');
      return 0.0;
    }
  }

  /// Get real ETH balance for an Ethereum wallet address
  static Future<double> getEthBalance(String walletAddress) async {
    // Try multiple RPC endpoints
    final rpcEndpoints = [
      _ethereumMainnetRpc, // Ankr (primary)
      _ethereumBackupRpc, // LlamaRPC (backup)
      _ethereumAlchemyRpc, // Alchemy (backup)
    ];

    for (int i = 0; i < rpcEndpoints.length; i++) {
      try {
        print(
            '🔍 Fetching ETH balance for: $walletAddress (RPC ${i + 1}/${rpcEndpoints.length})');

        final response = await http.post(
          Uri.parse(rpcEndpoints[i]),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'eth_getBalance',
            'params': [walletAddress, 'latest']
          }),
        );

        print('📡 ETH balance response: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('📊 ETH balance data: $data');

          // Check for RPC errors
          if (data['error'] != null) {
            print('⚠️ RPC error from ${rpcEndpoints[i]}: ${data['error']}');
            if (i < rpcEndpoints.length - 1) {
              print('🔄 Trying next RPC endpoint...');
              continue;
            }
            return 0.0;
          }

          if (data['result'] != null) {
            // Ethereum balance is in wei (1 ETH = 10^18 wei)
            final weiHex = data['result'] as String;
            final wei = int.parse(weiHex.substring(2), radix: 16);
            final ethBalance = wei / 1000000000000000000.0; // Convert to ETH

            print('💰 ETH balance: $ethBalance ETH');
            return ethBalance;
          }
        }

        print(
            '❌ Error fetching ETH balance: ${response.statusCode} - ${response.body}');
        if (i < rpcEndpoints.length - 1) {
          print('🔄 Trying next RPC endpoint...');
          continue;
        }
      } catch (e) {
        print('❌ Error fetching ETH balance from ${rpcEndpoints[i]}: $e');
        if (i < rpcEndpoints.length - 1) {
          print('🔄 Trying next RPC endpoint...');
          continue;
        }
      }
    }

    return 0.0;
  }

  /// Get real USDC balance for an Ethereum wallet address
  static Future<double> getUsdcBalance(String walletAddress) async {
    try {
      // USDC contract address on Ethereum mainnet (Circle's official USDC)
      const usdcContractAddress = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';

      final response = await http.post(
        Uri.parse(_ethereumMainnetRpc),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_call',
          'params': [
            {
              'to': usdcContractAddress,
              'data':
                  '0x70a08231000000000000000000000000${walletAddress.substring(2)}'
            },
            'latest'
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result'] != '0x') {
          // USDC has 6 decimals
          final balanceHex = data['result'] as String;

          // Remove '0x' prefix and validate hex string
          String cleanHex = balanceHex.startsWith('0x')
              ? balanceHex.substring(2)
              : balanceHex;

          // If empty or invalid, return 0
          if (cleanHex.isEmpty) {
            return 0.0;
          }

          try {
            final balance = int.parse(cleanHex, radix: 16);
            return balance / 1000000.0; // Convert to USDC
          } catch (e) {
            print('❌ Error parsing USDC hex: $cleanHex - $e');
            return 0.0;
          }
        }
      }

      print('❌ Error fetching USDC balance: ${response.statusCode}');
      return 0.0;
    } catch (e) {
      print('❌ Error fetching USDC balance: $e');
      return 0.0;
    }
  }

  /// Get real USDT balance for an Ethereum wallet address
  static Future<double> getUsdtBalance(String walletAddress) async {
    try {
      // USDT contract address on Ethereum mainnet
      const usdtContractAddress = '0xdAC17F958D2ee523a2206206994597C13D831ec7';

      final response = await http.post(
        Uri.parse(_ethereumMainnetRpc),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_call',
          'params': [
            {
              'to': usdtContractAddress,
              'data':
                  '0x70a08231000000000000000000000000${walletAddress.substring(2)}'
            },
            'latest'
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result'] != '0x') {
          // USDT has 6 decimals
          final balanceHex = data['result'] as String;

          // Remove '0x' prefix and validate hex string
          String cleanHex = balanceHex.startsWith('0x')
              ? balanceHex.substring(2)
              : balanceHex;

          // If empty or invalid, return 0
          if (cleanHex.isEmpty) {
            return 0.0;
          }

          try {
            final balance = int.parse(cleanHex, radix: 16);
            return balance / 1000000.0; // Convert to USDT
          } catch (e) {
            print('❌ Error parsing USDT hex: $cleanHex - $e');
            return 0.0;
          }
        }
      }

      print('❌ Error fetching USDT balance: ${response.statusCode}');
      return 0.0;
    } catch (e) {
      print('❌ Error fetching USDT balance: $e');
      return 0.0;
    }
  }

  /// Get all token balances for a wallet address
  static Future<Map<String, double>> getAllBalances(
      String walletAddress) async {
    try {
      print('🔍 Fetching real balances for wallet: $walletAddress');

      final balances = <String, double>{};

      // Determine blockchain type based on address format
      if (walletAddress.startsWith('0x') && walletAddress.length == 42) {
        // Ethereum address - fetch ETH, USDC, USDT
        print('📱 Detected Ethereum address, fetching ETH balances');

        // Add small delays to avoid rate limiting
        final ethBalance = await getEthBalance(walletAddress);
        await Future.delayed(const Duration(milliseconds: 500));

        final usdcBalance = await getUsdcBalance(walletAddress);
        await Future.delayed(const Duration(milliseconds: 500));

        final usdtBalance = await getUsdtBalance(walletAddress);

        balances['ETH'] = ethBalance;
        balances['USDC'] = usdcBalance;
        balances['USDT'] = usdtBalance;
        balances['SOL'] = 0.0; // No SOL on Ethereum
      } else if (walletAddress.length >= 32 && walletAddress.length <= 44) {
        // Solana address - fetch SOL
        print('📱 Detected Solana address, fetching SOL balance');
        final solBalance = await getSolBalance(walletAddress);

        balances['SOL'] = solBalance;
        balances['ETH'] = 0.0; // No ETH on Solana
        balances['USDC'] = 0.0; // No USDC on Solana
        balances['USDT'] = 0.0; // No USDT on Solana
      } else {
        print('❌ Unknown address format: $walletAddress');
        return {
          'SOL': 0.0,
          'ETH': 0.0,
          'USDC': 0.0,
          'USDT': 0.0,
        };
      }

      print('💰 Real balances fetched: $balances');
      return balances;
    } catch (e) {
      print('❌ Error fetching all balances: $e');
      return {
        'SOL': 0.0,
        'ETH': 0.0,
        'USDC': 0.0,
        'USDT': 0.0,
      };
    }
  }

  /// Check if a wallet address is valid
  static bool isValidWalletAddress(String address) {
    // Check if it's a valid Ethereum address (starts with 0x and is 42 characters)
    if (address.startsWith('0x') && address.length == 42) {
      return true;
    }

    // Check if it's a valid Solana address (base58, 32-44 characters)
    if (address.length >= 32 && address.length <= 44) {
      // Basic validation - in production, you'd use a proper base58 decoder
      return RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(address);
    }

    return false;
  }

  /// Get transaction history for a wallet (simplified)
  static Future<List<Map<String, dynamic>>> getTransactionHistory(
      String walletAddress) async {
    try {
      // This is a simplified implementation
      // In production, you'd use proper blockchain APIs
      return [
        {
          'hash': '0x123...abc',
          'type': 'receive',
          'amount': '0.526',
          'token': 'SOL',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'status': 'confirmed',
        },
        {
          'hash': '0x456...def',
          'type': 'send',
          'amount': '0.1',
          'token': 'ETH',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'status': 'confirmed',
        },
      ];
    } catch (e) {
      print('❌ Error fetching transaction history: $e');
      return [];
    }
  }
}
