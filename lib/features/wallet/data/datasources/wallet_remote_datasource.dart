import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:reown_appkit/reown_appkit.dart';
import '../../../../core/configs/env_config.dart';
import '../../../../shared/services/blockchain_balance_service.dart';

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
        print('✅ Wallet connection modal opened');

        // Wait for user to connect their wallet
        // This should be handled by proper event listeners
        throw Exception('Wallet connection requires user interaction');
      }

      throw Exception('Wallet connection modal not available');
    } catch (e) {
      print('❌ Wallet connection error: $e');
      rethrow;
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
      // Use real blockchain balance service
      final balances = await BlockchainBalanceService.getAllBalances(address);

      final tokenBalances = <Map<String, dynamic>>[];

      balances.forEach((symbol, balance) {
        if (balance > 0) {
          tokenBalances.add({
            'symbol': symbol,
            'balance': balance.toString(),
            'decimals': symbol == 'ETH' ? 18 : 6,
          });
        }
      });

      return tokenBalances;
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
      // Use real transaction signing with Reown AppKit
      // This requires proper implementation with the AppKit SDK
      throw Exception(
          'Transaction signing requires proper AppKit implementation');
    } catch (e) {
      print('❌ Transaction signing error: $e');
      rethrow;
    }
  }

  @override
  Future<String> sendTransaction(String transactionData) async {
    if (_connectedAddress == null) {
      throw Exception('Wallet not connected');
    }

    try {
      // Use real transaction sending with blockchain service
      throw Exception(
          'Real transaction sending requires blockchain service integration');
    } catch (e) {
      throw Exception('Failed to send transaction: $e');
    }
  }

  @override
  Future<bool> isWalletConnected() async {
    return _connectedAddress != null;
  }
}
