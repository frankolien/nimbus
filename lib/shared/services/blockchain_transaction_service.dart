import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../../core/configs/api_keys.dart';

class BlockchainTransactionService {
  // Ethereum RPC endpoints
  static String get _ethereumMainnetRpc =>
      'https://rpc.ankr.com/eth/${ApiKeys.ankrApiKey}';
  static const String _ethereumBackupRpc = 'https://eth.llamarpc.com';

  /// Send ETH transaction
  static Future<Map<String, dynamic>> sendEthTransaction({
    required String fromAddress,
    required String toAddress,
    required String privateKey,
    required String amountInEth,
    required String gasPrice,
    required String gasLimit,
  }) async {
    try {
      print(
          '🚀 Sending ETH transaction: $amountInEth ETH from $fromAddress to $toAddress');

      // Convert ETH to Wei
      final amountInWei =
          (double.parse(amountInEth) * 1000000000000000000).toInt();
      final amountHex = '0x${amountInWei.toRadixString(16)}';

      // Get nonce
      final nonce = await _getNonce(fromAddress);
      print('📊 Nonce: $nonce');

      // Create transaction
      final transaction = {
        'from': fromAddress,
        'to': toAddress,
        'value': amountHex,
        'gas': gasLimit,
        'gasPrice': gasPrice,
        'nonce': '0x${nonce.toRadixString(16)}',
        'data': '0x',
      };

      print('📝 Transaction: $transaction');

      // Sign transaction
      final signedTx = await _signTransaction(transaction, privateKey);
      print('✍️ Signed transaction: $signedTx');

      // Send transaction
      final txHash = await _sendRawTransaction(signedTx);
      print('✅ Transaction sent! Hash: $txHash');

      return {
        'success': true,
        'txHash': txHash,
        'amount': amountInEth,
        'from': fromAddress,
        'to': toAddress,
        'gasUsed': gasLimit,
        'gasPrice': gasPrice,
      };
    } catch (e) {
      print('❌ Error sending ETH transaction: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Send ERC-20 token transaction (USDC, USDT)
  static Future<Map<String, dynamic>> sendTokenTransaction({
    required String fromAddress,
    required String toAddress,
    required String privateKey,
    required String amount,
    required String tokenContract,
    required String gasPrice,
    required String gasLimit,
  }) async {
    try {
      print(
          '🚀 Sending token transaction: $amount tokens from $fromAddress to $toAddress');

      // Convert amount to token decimals (6 for USDC/USDT)
      final tokenAmount = (double.parse(amount) * 1000000).toInt();
      final amountHex = '0x${tokenAmount.toRadixString(16).padLeft(64, '0')}';

      // Create transfer function call data
      final transferData = '0xa9059cbb' + // transfer function selector
          toAddress.substring(2).padLeft(64, '0') + // to address
          amountHex; // amount

      // Get nonce
      final nonce = await _getNonce(fromAddress);

      // Create transaction
      final transaction = {
        'from': fromAddress,
        'to': tokenContract,
        'value': '0x0',
        'gas': gasLimit,
        'gasPrice': gasPrice,
        'nonce': '0x${nonce.toRadixString(16)}',
        'data': transferData,
      };

      print('📝 Token transaction: $transaction');

      // Sign and send transaction
      final signedTx = await _signTransaction(transaction, privateKey);
      final txHash = await _sendRawTransaction(signedTx);

      print('✅ Token transaction sent! Hash: $txHash');

      return {
        'success': true,
        'txHash': txHash,
        'amount': amount,
        'from': fromAddress,
        'to': toAddress,
        'tokenContract': tokenContract,
        'gasUsed': gasLimit,
        'gasPrice': gasPrice,
      };
    } catch (e) {
      print('❌ Error sending token transaction: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get transaction status
  static Future<Map<String, dynamic>> getTransactionStatus(
      String txHash) async {
    try {
      final response = await http.post(
        Uri.parse(_ethereumMainnetRpc),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_getTransactionReceipt',
          'params': [txHash]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null) {
          final receipt = data['result'];
          return {
            'success': true,
            'status': receipt['status'] == '0x1' ? 'confirmed' : 'failed',
            'blockNumber': receipt['blockNumber'],
            'gasUsed': receipt['gasUsed'],
            'transactionHash': receipt['transactionHash'],
          };
        }
      }

      return {
        'success': false,
        'status': 'pending',
        'error': 'Transaction not found or still pending',
      };
    } catch (e) {
      print('❌ Error getting transaction status: $e');
      return {
        'success': false,
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Get current gas price
  static Future<String> getGasPrice() async {
    try {
      final response = await http.post(
        Uri.parse(_ethereumMainnetRpc),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_gasPrice',
          'params': []
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? '0x5208'; // Default gas price
      }

      return '0x5208'; // 20 Gwei default
    } catch (e) {
      print('❌ Error getting gas price: $e');
      return '0x5208'; // 20 Gwei default
    }
  }

  /// Get nonce for address
  static Future<int> _getNonce(String address) async {
    try {
      final response = await http.post(
        Uri.parse(_ethereumMainnetRpc),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_getTransactionCount',
          'params': [address, 'latest']
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nonceHex = data['result'] as String;
        return int.parse(nonceHex.substring(2), radix: 16);
      }

      return 0;
    } catch (e) {
      print('❌ Error getting nonce: $e');
      return 0;
    }
  }

  /// Sign transaction with private key
  static Future<String> _signTransaction(
      Map<String, dynamic> transaction, String privateKey) async {
    try {
      // This is a simplified signing process
      // In production, you'd use a proper Ethereum signing library

      // Remove 0x prefix from private key
      final cleanPrivateKey =
          privateKey.startsWith('0x') ? privateKey.substring(2) : privateKey;

      // Create transaction hash (simplified)
      final txString = jsonEncode(transaction);
      final txHash = sha256.convert(utf8.encode(txString)).toString();

      // For demo purposes, return a mock signed transaction
      // In production, use proper ECDSA signing
      return '0x$txHash$cleanPrivateKey';
    } catch (e) {
      print('❌ Error signing transaction: $e');
      rethrow;
    }
  }

  /// Send raw transaction
  static Future<String> _sendRawTransaction(String signedTransaction) async {
    try {
      final response = await http.post(
        Uri.parse(_ethereumMainnetRpc),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_sendRawTransaction',
          'params': [signedTransaction]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null) {
          return data['result'] as String;
        }
      }

      throw Exception('Failed to send transaction');
    } catch (e) {
      print('❌ Error sending raw transaction: $e');
      rethrow;
    }
  }

  /// Estimate gas for transaction
  static Future<String> estimateGas(Map<String, dynamic> transaction) async {
    try {
      final response = await http.post(
        Uri.parse(_ethereumMainnetRpc),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_estimateGas',
          'params': [transaction]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? '0x5208'; // Default gas limit
      }

      return '0x5208'; // 21000 gas default
    } catch (e) {
      print('❌ Error estimating gas: $e');
      return '0x5208'; // 21000 gas default
    }
  }
}
