import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../wallet/domain/entities/network.dart';
import '../../wallet/domain/entities/network_cluster.dart';

/// Resolves the RPC/REST endpoint for each [Network] on a given [NetworkCluster].
///
/// On mainnet a user-supplied `.env` override wins (so production traffic can use
/// a keyed provider — Alchemy/Ankr/Helius); otherwise a sensible public default
/// is used. Test/Devnet always use the built-in public endpoints. Chains with no
/// literal devnet (EVM, Bitcoin) fall back to their nearest test network.
class RpcEndpoints {
  const RpcEndpoints();

  static const _endpoints = <String, Map<NetworkCluster, String>>{
    'ethereum': {
      NetworkCluster.mainnet: 'https://ethereum-rpc.publicnode.com',
      NetworkCluster.testnet: 'https://ethereum-sepolia-rpc.publicnode.com',
      NetworkCluster.devnet: 'https://ethereum-sepolia-rpc.publicnode.com',
    },
    'polygon': {
      NetworkCluster.mainnet: 'https://polygon-bor-rpc.publicnode.com',
      NetworkCluster.testnet: 'https://polygon-amoy-bor-rpc.publicnode.com',
      NetworkCluster.devnet: 'https://polygon-amoy-bor-rpc.publicnode.com',
    },
    'base': {
      NetworkCluster.mainnet: 'https://base-rpc.publicnode.com',
      NetworkCluster.testnet: 'https://base-sepolia-rpc.publicnode.com',
      NetworkCluster.devnet: 'https://base-sepolia-rpc.publicnode.com',
    },
    'solana': {
      NetworkCluster.mainnet: 'https://api.mainnet-beta.solana.com',
      NetworkCluster.testnet: 'https://api.testnet.solana.com',
      NetworkCluster.devnet: 'https://api.devnet.solana.com',
    },
    'sui': {
      NetworkCluster.mainnet: 'https://fullnode.mainnet.sui.io',
      NetworkCluster.testnet: 'https://fullnode.testnet.sui.io',
      NetworkCluster.devnet: 'https://fullnode.devnet.sui.io',
    },
    'bitcoin': {
      // Bitcoin uses a REST API (mempool.space), not JSON-RPC. No devnet — the
      // closest developer environment is testnet.
      NetworkCluster.mainnet: 'https://mempool.space/api',
      NetworkCluster.testnet: 'https://mempool.space/testnet/api',
      NetworkCluster.devnet: 'https://mempool.space/testnet/api',
    },
  };

  String urlFor(Network network,
      [NetworkCluster cluster = NetworkCluster.mainnet]) {
    if (cluster.isMainnet) {
      final override = dotenv.maybeGet(network.rpcEnvKey);
      if (override != null && override.trim().isNotEmpty) return override.trim();
    }
    final byCluster = _endpoints[network.id]!;
    return (byCluster[cluster] ?? byCluster[NetworkCluster.mainnet])!;
  }
}
