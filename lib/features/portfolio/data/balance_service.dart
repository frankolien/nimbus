import '../../../core/network/resilient_http.dart';
import '../../wallet/domain/entities/chain_family.dart';
import '../../wallet/domain/entities/network.dart';
import '../../wallet/domain/entities/network_cluster.dart';
import 'rpc_endpoints.dart';

/// The native-asset balance of one address on one network.
class NativeBalance {
  const NativeBalance({
    required this.network,
    required this.address,
    required this.amount,
  });

  final Network network;
  final String address;

  /// Balance in whole native units (e.g. ETH, SOL, BTC), not the base unit.
  final double amount;
}

/// Fetches native balances from each chain's RPC/REST endpoint. Every call goes
/// through [ResilientHttp], so timeouts/transient errors are retried.
class BalanceService {
  BalanceService({ResilientHttp? http, RpcEndpoints endpoints = const RpcEndpoints()})
      : _http = http ?? ResilientHttp(),
        _endpoints = endpoints;

  final ResilientHttp _http;
  final RpcEndpoints _endpoints;

  Future<NativeBalance> fetch(Network network, String address,
      [NetworkCluster cluster = NetworkCluster.mainnet]) async {
    final raw = switch (network.family) {
      ChainFamily.evm => await _evm(network, address, cluster),
      ChainFamily.solana => await _solana(network, address, cluster),
      ChainFamily.sui => await _sui(network, address, cluster),
      ChainFamily.bitcoin => await _bitcoin(network, address, cluster),
    };
    final amount = raw / _pow10(network.nativeDecimals);
    return NativeBalance(network: network, address: address, amount: amount);
  }

  // eth_getBalance -> hex wei
  Future<double> _evm(
      Network network, String address, NetworkCluster cluster) async {
    final json =
        await _http.postJson(Uri.parse(_endpoints.urlFor(network, cluster)), {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'eth_getBalance',
      'params': [address, 'latest'],
    });
    final hex = (json['result'] as String).replaceFirst('0x', '');
    return BigInt.parse(hex, radix: 16).toDouble();
  }

  // getBalance -> lamports
  Future<double> _solana(
      Network network, String address, NetworkCluster cluster) async {
    final json =
        await _http.postJson(Uri.parse(_endpoints.urlFor(network, cluster)), {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'getBalance',
      'params': [address],
    });
    return ((json['result']?['value']) as num).toDouble();
  }

  // suix_getBalance -> totalBalance (MIST, as string)
  Future<double> _sui(
      Network network, String address, NetworkCluster cluster) async {
    final json =
        await _http.postJson(Uri.parse(_endpoints.urlFor(network, cluster)), {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'suix_getBalance',
      'params': [address],
    });
    return double.parse(json['result']['totalBalance'] as String);
  }

  // mempool.space REST -> funded - spent (sats)
  Future<double> _bitcoin(
      Network network, String address, NetworkCluster cluster) async {
    final base = _endpoints.urlFor(network, cluster);
    final json = await _http.getJson(Uri.parse('$base/address/$address'));
    final stats = json['chain_stats'] as Map<String, dynamic>;
    final funded = (stats['funded_txo_sum'] as num).toDouble();
    final spent = (stats['spent_txo_sum'] as num).toDouble();
    return funded - spent;
  }

  double _pow10(int n) {
    var r = 1.0;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}
