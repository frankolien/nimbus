import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../../portfolio/data/rpc_endpoints.dart';
import '../../wallet/domain/entities/network.dart';
import '../../wallet/domain/entities/network_cluster.dart';

/// Builds, signs, and broadcasts a native-asset transfer on an EVM network.
/// web3dart fills in the nonce and gas price from the node automatically.
class EvmSendService {
  EvmSendService({http.Client? client, RpcEndpoints endpoints = const RpcEndpoints()})
      : _client = client ?? http.Client(),
        _endpoints = endpoints;

  final http.Client _client;
  final RpcEndpoints _endpoints;

  /// Send [amountEther] of the native asset on [network] from the key
  /// [privateKeyHex] to [toAddress]. Returns the transaction hash.
  Future<String> sendNative({
    required Network network,
    required String privateKeyHex,
    required String toAddress,
    required String amountEther,
    NetworkCluster cluster = NetworkCluster.mainnet,
  }) async {
    if (!network.isEvm) {
      throw ArgumentError('sendNative only supports EVM networks');
    }
    final web3 = Web3Client(_endpoints.urlFor(network, cluster), _client);
    try {
      final credentials = EthPrivateKey.fromHex(privateKeyHex);
      final tx = Transaction(
        to: EthereumAddress.fromHex(toAddress),
        value: EtherAmount.fromBase10String(EtherUnit.ether, amountEther),
        maxGas: 21000, // plain native transfer
      );
      return await web3.sendTransaction(
        credentials,
        tx,
        chainId: network.evmChainId,
      );
    } finally {
      web3.dispose();
    }
  }

  /// Validates an EVM recipient address (throws if malformed).
  static bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (_) {
      return false;
    }
  }
}
