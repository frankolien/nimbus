import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import '../../../../shared/services/blockchain_balance_service.dart';

class CustodialWalletService {
  static const String _storageKeyPrefix = 'custodial_wallet_';
  static const String _privateKeyKey = 'private_key';
  static const String _addressKey = 'address';
  static const String _mnemonicKey = 'mnemonic';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Generate a new custodial wallet for a user
  Future<CustodialWallet> generateWallet(String userId) async {
    try {
      // Generate a new Ethereum wallet
      final credentials = EthPrivateKey.createRandom(Random.secure());
      final address = credentials.address;
      final privateKey = credentials;

      // Generate a mnemonic phrase (optional, for backup)
      final mnemonic = _generateMnemonic();

      // Store securely
      final privateKeyHex =
          '0x${privateKey.privateKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

      // Validate the generated hex string
      if (privateKeyHex.length != 66 ||
          !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(privateKeyHex)) {
        throw CustodialWalletException('Generated invalid private key format');
      }

      print('🔐 Generated wallet for user: $userId');
      print('🔐 Address: ${address.hex}');
      print('🔐 Private key length: ${privateKeyHex.length}');
      print('🔐 Private key preview: ${privateKeyHex.substring(0, 10)}...');
      print('🔐 Private key format validation: ✅');

      await _storeWalletData(userId, {
        _privateKeyKey: privateKeyHex,
        _addressKey: address.hex,
        _mnemonicKey: mnemonic,
      });

      return CustodialWallet(
        userId: userId,
        address: address.hex,
        privateKey: privateKey,
        mnemonic: mnemonic,
        isActive: true,
      );
    } catch (e) {
      throw CustodialWalletException('Failed to generate wallet: $e');
    }
  }

  /// Load existing wallet for a user
  Future<CustodialWallet?> loadWallet(String userId) async {
    try {
      final privateKeyStr = await _secureStorage.read(
          key: '${_storageKeyPrefix}${userId}_$_privateKeyKey');
      final addressStr = await _secureStorage.read(
          key: '${_storageKeyPrefix}${userId}_$_addressKey');
      final mnemonic = await _secureStorage.read(
          key: '${_storageKeyPrefix}${userId}_$_mnemonicKey');

      print('🔍 Loading wallet for user: $userId');
      print('🔍 Private key length: ${privateKeyStr?.length}');
      print('🔍 Address: $addressStr');

      if (privateKeyStr == null || addressStr == null) {
        print('❌ No wallet found for user: $userId');
        return null;
      }

      // Ensure the private key string is properly formatted
      String cleanPrivateKeyStr = privateKeyStr;

      // Check if it's already corrupted (contains brackets from Uint8List.toString())
      if (cleanPrivateKeyStr.contains('[') ||
          cleanPrivateKeyStr.contains(']')) {
        print('❌ Corrupted private key format detected, clearing data');
        throw FormatException('Corrupted private key format');
      }

      if (!cleanPrivateKeyStr.startsWith('0x')) {
        cleanPrivateKeyStr = '0x$cleanPrivateKeyStr';
      }

      // Validate hex format
      if (cleanPrivateKeyStr.length != 66 ||
          !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(cleanPrivateKeyStr)) {
        print(
            '❌ Invalid private key format: length=${cleanPrivateKeyStr.length}');
        throw FormatException('Invalid private key format');
      }

      print('🔍 Clean private key: ${cleanPrivateKeyStr.substring(0, 10)}...');
      print(
          '🔍 Private key length after cleaning: ${cleanPrivateKeyStr.length}');

      final privateKey = EthPrivateKey.fromHex(cleanPrivateKeyStr);

      return CustodialWallet(
        userId: userId,
        address: addressStr,
        privateKey: privateKey,
        mnemonic: mnemonic ?? '',
        isActive: true,
      );
    } catch (e) {
      throw CustodialWalletException('Failed to load wallet: $e');
    }
  }

  /// Create or load wallet for user
  Future<CustodialWallet> getOrCreateWallet(String userId) async {
    try {
      final existingWallet = await loadWallet(userId);
      if (existingWallet != null) {
        return existingWallet;
      }
    } catch (e) {
      print('⚠️ Error loading existing wallet, clearing corrupted data: $e');
      await deleteWallet(userId);
    }
    return await generateWallet(userId);
  }

  /// Sign a transaction with the custodial wallet
  Future<String> signTransaction(String userId, Transaction transaction) async {
    try {
      final wallet = await loadWallet(userId);
      if (wallet == null) {
        throw CustodialWalletException('Wallet not found for user: $userId');
      }

      // Sign the transaction
      // Real transaction signing implementation required
      throw Exception(
          'Real transaction signing requires web3dart implementation');
    } catch (e) {
      throw CustodialWalletException('Failed to sign transaction: $e');
    }
  }

  /// Send a transaction using the custodial wallet
  Future<String> sendTransaction(String userId, Transaction transaction) async {
    try {
      final wallet = await loadWallet(userId);
      if (wallet == null) {
        throw CustodialWalletException('Wallet not found for user: $userId');
      }

      // This would typically involve sending to a blockchain node
      // Real transaction execution implementation required
      throw Exception(
          'Real transaction execution requires blockchain service integration');
    } catch (e) {
      throw CustodialWalletException('Failed to send transaction: $e');
    }
  }

  /// Get wallet balance
  Future<double> getWalletBalance(String userId) async {
    try {
      final wallet = await loadWallet(userId);
      if (wallet == null) {
        return 0.0;
      }

      // Use real blockchain balance service
      final balances =
          await BlockchainBalanceService.getAllBalances(wallet.address);

      // Return ETH balance as primary balance
      return balances['ETH'] ?? 0.0;
    } catch (e) {
      throw CustodialWalletException('Failed to get balance: $e');
    }
  }

  /// Delete wallet (for testing/cleanup)
  Future<void> deleteWallet(String userId) async {
    try {
      await _secureStorage.delete(
          key: '${_storageKeyPrefix}${userId}_$_privateKeyKey');
      await _secureStorage.delete(
          key: '${_storageKeyPrefix}${userId}_$_addressKey');
      await _secureStorage.delete(
          key: '${_storageKeyPrefix}${userId}_$_mnemonicKey');
    } catch (e) {
      throw CustodialWalletException('Failed to delete wallet: $e');
    }
  }

  /// Store wallet data securely
  Future<void> _storeWalletData(String userId, Map<String, String> data) async {
    for (final entry in data.entries) {
      await _secureStorage.write(
        key: '${_storageKeyPrefix}${userId}_${entry.key}',
        value: entry.value,
      );
    }
  }

  /// Generate a simple mnemonic (in production, use a proper BIP39 library)
  String _generateMnemonic() {
    final words = [
      'abandon',
      'ability',
      'able',
      'about',
      'above',
      'absent',
      'absorb',
      'abstract',
      'absurd',
      'abuse',
      'access',
      'accident',
      'account',
      'accuse',
      'achieve',
      'acid',
      'acoustic',
      'acquire',
      'across',
      'act',
      'action',
      'actor',
      'actress',
      'actual',
      'adapt',
      'add',
      'addict',
      'address',
      'adjust',
      'admit',
      'adult',
      'advance',
      'advice',
      'aerobic',
      'affair',
      'afford',
      'afraid',
      'again',
      'age',
      'agent',
      'agree',
      'ahead',
      'aim',
      'air',
      'airport',
      'aisle',
      'alarm',
      'album',
    ];

    final random = Random.secure();
    final selectedWords = <String>[];
    for (int i = 0; i < 12; i++) {
      selectedWords.add(words[random.nextInt(words.length)]);
    }

    return selectedWords.join(' ');
  }
}

/// Custodial wallet data model
class CustodialWallet {
  final String userId;
  final String address;
  final EthPrivateKey privateKey;
  final String mnemonic;
  final bool isActive;

  CustodialWallet({
    required this.userId,
    required this.address,
    required this.privateKey,
    required this.mnemonic,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'address': address,
      'mnemonic': mnemonic,
      'isActive': isActive,
    };
  }

  factory CustodialWallet.fromJson(Map<String, dynamic> json) {
    return CustodialWallet(
      userId: json['userId'],
      address: json['address'],
      privateKey: EthPrivateKey.fromHex(json['privateKey']),
      mnemonic: json['mnemonic'],
      isActive: json['isActive'],
    );
  }
}

/// Custom exception for custodial wallet operations
class CustodialWalletException implements Exception {
  final String message;
  CustodialWalletException(this.message);

  @override
  String toString() => 'CustodialWalletException: $message';
}
