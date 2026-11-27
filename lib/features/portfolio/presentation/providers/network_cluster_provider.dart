import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../wallet/domain/entities/network_cluster.dart';

/// The cluster the app runs on. Balances, sends and history all go through the
/// Xend backend, which runs on Solana devnet, so this is fixed to devnet. Other
/// clusters can't be selected until the backend serves them.
class NetworkClusterNotifier extends StateNotifier<NetworkCluster> {
  NetworkClusterNotifier() : super(backendCluster);

  static const backendCluster = NetworkCluster.devnet;

  /// Kept for callers like the network picker. Anything other than the backend's
  /// cluster is ignored.
  Future<void> set(NetworkCluster cluster) async {
    if (cluster == backendCluster) state = cluster;
  }
}

final networkClusterProvider =
    StateNotifierProvider<NetworkClusterNotifier, NetworkCluster>(
        (ref) => NetworkClusterNotifier());
