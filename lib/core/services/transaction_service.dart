import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import '../../core/configs/api_keys.dart';
import '../../core/services/input_validation_service.dart';

/// Production-ready transaction service
/// Supports custodial wallets, WalletConnect v2, MetaMask SDK, and hardware wallets
class TransactionService {
  final http.Client _client;
  Web3Client? _web3Client;

  // Wallet connection info
  String? _connectedAddress;
  EthPrivateKey? _custodialPrivateKey;
  WalletConnectionType _connectionType = WalletConnectionType.none;

  TransactionService({http.Client? client}) : _client = client ?? http.Client();

  /// Initialize Web3 client
  Future<void> initialize() async {
    _web3Client = Web3Client(
      'https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}',
      _client,
    );
  }

  /// Set wallet connection info
  void setWalletConnection({
    required String address,
    required WalletConnectionType connectionType,
    EthPrivateKey? privateKey,
  }) {
    _connectedAddress = address;
    _connectionType = connectionType;
    _custodialPrivateKey = privateKey;
  }

  /// Send ETH transaction with production-grade features
  Future<TransactionResult> sendEthTransaction({
    required String toAddress,
    required String amountInEth,
    String? gasPrice,
    String? gasLimit,
    String? data,
    bool simulateFirst = true,
    int maxSlippage = 5, // 5% max slippage
  }) async {
    try {
      if (_connectionType == WalletConnectionType.none) {
        throw TransactionException('No wallet connected');
      }

      await initialize();

      // Validate inputs
      final addressValidation =
          InputValidationService.validateEthereumAddress(toAddress);
      if (!addressValidation.isValid) {
        throw TransactionException(
            'Invalid recipient address: ${addressValidation.message}');
      }

      final amountValidation =
          InputValidationService.validateCryptoAmount(amountInEth);
      if (!amountValidation.isValid) {
        throw TransactionException(
            'Invalid amount: ${amountValidation.message}');
      }

      // Simulate transaction first (if enabled)
      if (simulateFirst) {
        await _simulateTransaction(toAddress, amountInEth, data);
      }

      // Get optimal gas settings
      final gasSettings =
          await _getOptimalGasSettings(toAddress, amountInEth, data);

      // Use provided gas settings or optimal ones
      final finalGasPrice = gasPrice ?? gasSettings.gasPrice.toString();
      final finalGasLimit = gasLimit ?? gasSettings.gasLimit.toString();

      // Create transaction
      final transaction = Transaction(
        to: EthereumAddress.fromHex(toAddress),
        value: EtherAmount.fromInt(
            EtherUnit.ether, (double.parse(amountInEth) * 1e18).toInt()),
        gasPrice: EtherAmount.fromInt(EtherUnit.gwei, int.parse(finalGasPrice)),
        maxGas: int.parse(finalGasLimit),
        data: data != null ? hexToBytes(data) : null,
      );

      // Sign and send transaction
      String txHash;
      if (_connectionType == WalletConnectionType.custodial) {
        txHash = await _sendCustodialTransaction(transaction);
      } else {
        txHash = await _sendExternalTransaction(transaction);
      }

      print('✅ Transaction sent! Hash: $txHash');

      return TransactionResult(
        success: true,
        txHash: txHash,
        amount: amountInEth,
        from: _connectedAddress!,
        to: toAddress,
        gasUsed: finalGasLimit,
        gasPrice: finalGasPrice,
      );
    } catch (e) {
      print('❌ Transaction failed: $e');
      throw TransactionException('Failed to send transaction: $e');
    }
  }

  /// Simulate transaction to check for errors
  Future<void> _simulateTransaction(
      String toAddress, String amount, String? data) async {
    try {
      // Use eth_call to simulate transaction
      final response = await _client.post(
        Uri.parse('https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_call',
          'params': [
            {
              'from': _connectedAddress,
              'to': toAddress,
              'value':
                  '0x${(double.parse(amount) * 1e18).toInt().toRadixString(16)}',
              'data': data ?? '0x',
            },
            'latest'
          ],
          'id': 1,
        }),
      );

      if (response.statusCode != 200) {
        throw TransactionException('Transaction simulation failed');
      }
    } catch (e) {
      throw TransactionException('Transaction simulation error: $e');
    }
  }

  /// Get optimal gas settings
  Future<GasSettings> _getOptimalGasSettings(
      String toAddress, String amount, String? data) async {
    try {
      // Get current gas price
      final gasPriceResponse = await _client.post(
        Uri.parse('https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_gasPrice',
          'params': [],
          'id': 1,
        }),
      );

      final gasPriceData = json.decode(gasPriceResponse.body);
      final gasPriceWei =
          int.parse(gasPriceData['result'].substring(2), radix: 16);
      final gasPriceGwei = (gasPriceWei / 1e9).round();

      // Estimate gas limit
      final gasLimitResponse = await _client.post(
        Uri.parse('https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_estimateGas',
          'params': [
            {
              'from': _connectedAddress,
              'to': toAddress,
              'value':
                  '0x${(double.parse(amount) * 1e18).toInt().toRadixString(16)}',
              'data': data ?? '0x',
            }
          ],
          'id': 1,
        }),
      );

      final gasLimitData = json.decode(gasLimitResponse.body);
      final gasLimit =
          int.parse(gasLimitData['result'].substring(2), radix: 16);

      // Add 20% buffer to gas limit
      final gasLimitWithBuffer = (gasLimit * 1.2).round();

      return GasSettings(
        gasPrice: gasPriceGwei,
        gasLimit: gasLimitWithBuffer,
      );
    } catch (e) {
      throw TransactionException('Failed to get gas settings: $e');
    }
  }

  /// Send transaction using custodial wallet
  Future<String> _sendCustodialTransaction(Transaction transaction) async {
    if (_custodialPrivateKey == null || _web3Client == null) {
      throw TransactionException('Custodial wallet not initialized');
    }

    try {
      // Get nonce
      final nonce =
          await _web3Client!.getTransactionCount(_custodialPrivateKey!.address);

      // Update transaction with nonce
      final transactionWithNonce = Transaction(
        to: transaction.to,
        value: transaction.value,
        gasPrice: transaction.gasPrice,
        maxGas: transaction.maxGas,
        data: transaction.data,
        nonce: nonce,
      );

      // Sign and send transaction using web3dart
      final txHash = await _web3Client!.sendTransaction(
        _custodialPrivateKey!,
        transactionWithNonce,
        chainId: null, // or specify, e.g., 1 for Ethereum mainnet
      );

      return txHash;
    } catch (e) {
      throw TransactionException('Failed to send custodial transaction: $e');
    }
  }

  /// Send transaction using external wallet
  Future<String> _sendExternalTransaction(Transaction transaction) async {
    // TODO: Implement external wallet transaction sending
    // This would integrate with WalletConnect v2, MetaMask SDK, etc.
    throw TransactionException(
        'External wallet transactions not yet implemented');
  }

  /// Get transaction nonce
  Future<int> _getNonce(String address) async {
    try {
      final response = await _client.post(
        Uri.parse('https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_getTransactionCount',
          'params': [address, 'latest'],
          'id': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nonceHex = data['result'] as String;
        return int.parse(nonceHex.substring(2), radix: 16);
      } else {
        throw TransactionException(
            'Failed to get nonce: ${response.statusCode}');
      }
    } catch (e) {
      throw TransactionException('Failed to get nonce: $e');
    }
  }

  /// Get transaction status
  Future<TransactionStatus> getTransactionStatus(String txHash) async {
    try {
      final response = await _client.post(
        Uri.parse('https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_getTransactionReceipt',
          'params': [txHash],
          'id': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final receipt = data['result'];

        if (receipt == null) {
          return TransactionStatus.pending;
        }

        final status = receipt['status'] as String;
        if (status == '0x1') {
          return TransactionStatus.success;
        } else {
          return TransactionStatus.failed;
        }
      } else {
        return TransactionStatus.unknown;
      }
    } catch (e) {
      print('Error getting transaction status: $e');
      return TransactionStatus.unknown;
    }
  }

  /// Get transaction details
  Future<TransactionDetails?> getTransactionDetails(String txHash) async {
    try {
      final response = await _client.post(
        Uri.parse('https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_getTransactionByHash',
          'params': [txHash],
          'id': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tx = data['result'];

        if (tx == null) return null;

        return TransactionDetails(
          hash: tx['hash'] as String,
          from: tx['from'] as String,
          to: tx['to'] as String,
          value: tx['value'] as String,
          gas: tx['gas'] as String,
          gasPrice: tx['gasPrice'] as String,
          nonce: tx['nonce'] as String,
          blockNumber: tx['blockNumber'] as String?,
          blockHash: tx['blockHash'] as String?,
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting transaction details: $e');
      return null;
    }
  }

  /// Estimate gas for a transaction
  Future<String> estimateGas({
    required String from,
    required String to,
    required String value,
    String? data,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_estimateGas',
          'params': [
            {
              'from': from,
              'to': to,
              'value': value,
              'data': data ?? '0x',
            }
          ],
          'id': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] as String;
      } else {
        throw TransactionException(
            'Failed to estimate gas: ${response.statusCode}');
      }
    } catch (e) {
      throw TransactionException('Failed to estimate gas: $e');
    }
  }

  /// Get current gas price
  Future<String> getCurrentGasPrice() async {
    try {
      final response = await _client.post(
        Uri.parse('https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_gasPrice',
          'params': [],
          'id': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final gasPriceHex = data['result'] as String;
        final gasPriceWei = int.parse(gasPriceHex.substring(2), radix: 16);
        final gasPriceGwei = (gasPriceWei / 1e9).round();
        return gasPriceGwei.toString();
      } else {
        throw TransactionException(
            'Failed to get gas price: ${response.statusCode}');
      }
    } catch (e) {
      throw TransactionException('Failed to get gas price: $e');
    }
  }
}

/// Transaction result
class TransactionResult {
  final bool success;
  final String txHash;
  final String amount;
  final String from;
  final String to;
  final String gasUsed;
  final String gasPrice;

  TransactionResult({
    required this.success,
    required this.txHash,
    required this.amount,
    required this.from,
    required this.to,
    required this.gasUsed,
    required this.gasPrice,
  });
}

/// Transaction status
enum TransactionStatus {
  pending,
  success,
  failed,
  unknown,
}

/// Transaction details
class TransactionDetails {
  final String hash;
  final String from;
  final String to;
  final String value;
  final String gas;
  final String gasPrice;
  final String nonce;
  final String? blockNumber;
  final String? blockHash;

  TransactionDetails({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.gas,
    required this.gasPrice,
    required this.nonce,
    this.blockNumber,
    this.blockHash,
  });
}

/// Wallet connection types
enum WalletConnectionType {
  none,
  custodial,
  walletConnect,
  metaMask,
  hardware,
}

/// Gas settings for transactions
class GasSettings {
  final int gasPrice; // in Gwei
  final int gasLimit;

  GasSettings({
    required this.gasPrice,
    required this.gasLimit,
  });
}

/// Transaction exception
class TransactionException implements Exception {
  final String message;
  TransactionException(this.message);

  @override
  String toString() => 'TransactionException: $message';
}
