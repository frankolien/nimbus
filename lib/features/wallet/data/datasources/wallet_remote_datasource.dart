import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:reown_appkit/reown_appkit.dart';
import '../../../../core/configs/env_config.dart';

abstract class WalletRemoteDataSource {
  Future<String> connectWallet();
  Future<void> disconnectWallet();
  Future<String> getWalletAddress();
  Future<List<Map<String, dynamic>>> getTokenBalances(String address);
  Future<double> getNativeBalance(String address);
  Future<String> signTransaction(String transactionData);
  Future<String> sendTransaction(String transactionData);
  Future<bool> isWalletConnected();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Web3Client _web3Client;
  String? _connectedAddress;
  ReownAppKitModal? _appKitModal;
  BuildContext? _context;

  WalletRemoteDataSourceImpl(this._web3Client);

  // Initialize with BuildContext (required for ReownAppKitModal)
  Future<void> initialize(BuildContext context) async {
    _context = context;
    if (EnvConfig.walletConnectProjectId.isNotEmpty) {
      _appKitModal = ReownAppKitModal(
        context: context,
        projectId: EnvConfig.walletConnectProjectId,
        metadata: const PairingMetadata(
          name: 'Nimbus',
          description: 'Web3 dApp for trading and portfolio management',
          url: 'https://nimbus.app',
          icons: ['https://nimbus.app/icon.png'],
          redirect: Redirect(
            native: 'nimbus://',
            universal: 'https://nimbus.app',
            linkMode: true,
          ),
        ),
        enableAnalytics: true,
        disconnectOnDispose: true,
      );

      await _appKitModal!.init();
      print('✅ Reown AppKit initialized');
    }
  }

  @override
  Future<String> connectWallet() async {
    try {
      if (_appKitModal != null && _context != null) {
        // Open the wallet connection modal
        _appKitModal!.openModalView();

        // For now, using mock implementation
        // TODO: Implement proper event listening for connection
        await Future.delayed(const Duration(seconds: 2));

        // Mock connected address
        _connectedAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';
        print('✅ Wallet connection modal opened');
        return _connectedAddress!;
      }

      // Fallback to mock implementation
      await Future.delayed(const Duration(seconds: 1));
      _connectedAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';
      print('🔄 Using mock wallet: $_connectedAddress');
      return _connectedAddress!;
    } catch (e) {
      print('❌ Wallet connection error: $e');
      // Fallback to mock for development
      await Future.delayed(const Duration(seconds: 1));
      _connectedAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';
      return _connectedAddress!;
    }
  }

  @override
  Future<void> disconnectWallet() async {
    if (_appKitModal != null) {
      try {
        _appKitModal!.disconnect();
        print('✅ Wallet disconnected successfully');
      } catch (e) {
        print('❌ Error disconnecting wallet: $e');
      }
    }
    _connectedAddress = null;
  }

  @override
  Future<String> getWalletAddress() async {
    if (_connectedAddress == null) {
      throw Exception('Wallet not connected');
    }
    return _connectedAddress!;
  }

  @override
  Future<List<Map<String, dynamic>>> getTokenBalances(String address) async {
    try {
      // Mock token balances for development
      return [
        {
          'symbol': 'ETH',
          'balance': '0.0', // Real balance will be fetched from blockchain
          'decimals': 18,
        },
        {
          'symbol': 'USDC',
          'balance': '0.0', // Real balance will be fetched from blockchain
          'decimals': 6,
        },
      ];
    } catch (e) {
      throw Exception('Failed to get token balances: $e');
    }
  }

  @override
  Future<double> getNativeBalance(String address) async {
    try {
      final ethAddress = EthereumAddress.fromHex(address);
      final balance = await _web3Client.getBalance(ethAddress);
      return balance.getInWei.toDouble() / 1e18; // Convert from wei to ETH
    } catch (e) {
      throw Exception('Failed to get native balance: $e');
    }
  }

  @override
  Future<String> signTransaction(String transactionData) async {
    if (_appKitModal == null) {
      throw Exception('Wallet not connected');
    }

    try {
      // For now, using mock implementation
      // TODO: Implement proper transaction signing with Reown AppKit
      await Future.delayed(const Duration(seconds: 1));
      final txHash =
          '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
      print('✅ Transaction signed (mock): $txHash');
      return txHash;
    } catch (e) {
      print('❌ Transaction signing error: $e');
      // Fallback to mock for development
      await Future.delayed(const Duration(seconds: 1));
      final txHash =
          '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
      print('🔄 Using mock transaction: $txHash');
      return txHash;
    }
  }

  @override
  Future<String> sendTransaction(String transactionData) async {
    if (_connectedAddress == null) {
      throw Exception('Wallet not connected');
    }

    try {
      // Mock transaction sending
      await Future.delayed(const Duration(seconds: 2));
      return '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    } catch (e) {
      throw Exception('Failed to send transaction: $e');
    }
  }

  @override
  Future<bool> isWalletConnected() async {
    return _connectedAddress != null;
  }
}
