import 'dart:convert';

import 'package:blockchain_utils/blockchain_utils.dart';

import '../../../core/network/resilient_http.dart';
import '../../portfolio/data/rpc_endpoints.dart';
import '../../wallet/domain/entities/network.dart';
import '../../wallet/domain/entities/network_cluster.dart';
import 'solana_transaction.dart';

/// Thrown when a Solana RPC returns a JSON-RPC error (HTTP 200 with `error`).
class SolanaRpcException implements Exception {
  SolanaRpcException(this.message);
  final String message;
  @override
  String toString() => 'SolanaRpcException: $message';
}

/// Builds, signs, and broadcasts native SOL transfers, and (on non-mainnet)
/// requests faucet airdrops. Targets whichever [NetworkCluster] is passed, so
/// the same code path serves Mainnet, Testnet, and Devnet.
class SolanaSendService {
  SolanaSendService({
    ResilientHttp? http,
    RpcEndpoints endpoints = const RpcEndpoints(),
  })  : _http = http ?? ResilientHttp(),
        _endpoints = endpoints;

  final ResilientHttp _http;
  final RpcEndpoints _endpoints;

  static const _lamportsPerSol = 1000000000; // 1e9

  /// Transfer [amountSol] of SOL from [fromAddress] to [toAddress], signing with
  /// the account's raw ed25519 [privateKeyBytes]. Returns the transaction
  /// signature (base58).
  Future<String> sendNative({
    required String fromAddress,
    required List<int> privateKeyBytes,
    required String toAddress,
    required String amountSol,
    required NetworkCluster cluster,
  }) async {
    final url = Uri.parse(_endpoints.urlFor(Network.solana, cluster));

    final blockhash = await _latestBlockhash(url);
    final message = SolanaTransfer.buildMessage(
      from: Base58Decoder.decode(fromAddress),
      to: Base58Decoder.decode(toAddress),
      recentBlockhash: Base58Decoder.decode(blockhash),
      lamports: _toLamports(amountSol),
    );
    final signature = Ed25519Signer.fromKeyBytes(privateKeyBytes).sign(message);
    final tx = SolanaTransfer.buildSignedTransaction(
      message: message,
      signature: signature,
    );

    final res = await _rpc(url, 'sendTransaction', [
      base64.encode(tx),
      {'encoding': 'base64', 'preflightCommitment': 'confirmed'},
    ]);
    return res as String;
  }

  /// Request a faucet airdrop of [sol] SOL to [address]. Only works on
  /// Testnet/Devnet — mainnet has no faucet. Returns the airdrop signature.
  Future<String> requestAirdrop({
    required String address,
    required NetworkCluster cluster,
    double sol = 1,
  }) async {
    if (cluster.isMainnet) {
      throw SolanaRpcException('Airdrops are only available on Devnet/Testnet');
    }
    final url = Uri.parse(_endpoints.urlFor(Network.solana, cluster));
    final lamports = (sol * _lamportsPerSol).round();
    final res = await _rpc(url, 'requestAirdrop', [address, lamports]);
    return res as String;
  }

  Future<String> _latestBlockhash(Uri url) async {
    final res = await _rpc(url, 'getLatestBlockhash', [
      {'commitment': 'finalized'},
    ]);
    return (res as Map<String, dynamic>)['value']['blockhash'] as String;
  }

  /// One JSON-RPC round trip. Throws [SolanaRpcException] on a JSON-RPC error.
  Future<dynamic> _rpc(Uri url, String method, List<dynamic> params) async {
    final json = await _http.postJson(url, {
      'jsonrpc': '2.0',
      'id': 1,
      'method': method,
      'params': params,
    }) as Map<String, dynamic>;
    final error = json['error'];
    if (error != null) {
      throw SolanaRpcException(
          error is Map ? (error['message']?.toString() ?? '$error') : '$error');
    }
    return json['result'];
  }

  BigInt _toLamports(String amountSol) {
    final sol = double.parse(amountSol.trim());
    return BigInt.from((sol * _lamportsPerSol).round());
  }

  /// A syntactically valid Solana address is base58 that decodes to 32 bytes.
  static bool isValidAddress(String address) {
    try {
      return Base58Decoder.decode(address.trim()).length == 32;
    } catch (_) {
      return false;
    }
  }
}
