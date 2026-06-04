import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../wallet/domain/entities/network_cluster.dart';

/// The active [NetworkCluster] for the whole app, persisted so it survives
/// restarts. Switching it makes balances (and later transactions) target a
/// different environment across every chain. Defaults to mainnet.
class NetworkClusterNotifier extends StateNotifier<NetworkCluster> {
  NetworkClusterNotifier() : super(NetworkCluster.mainnet) {
    _load();
  }

  static const _key = 'network.cluster.v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_key);
      if (id != null) state = NetworkCluster.fromId(id);
    } catch (e) {
      debugPrint('NetworkCluster load failed: $e');
    }
  }

  Future<void> set(NetworkCluster cluster) async {
    if (cluster == state) return;
    state = cluster;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, cluster.id);
    } catch (e) {
      debugPrint('NetworkCluster save failed: $e');
    }
  }
}

final networkClusterProvider =
    StateNotifierProvider<NetworkClusterNotifier, NetworkCluster>(
        (ref) => NetworkClusterNotifier());
