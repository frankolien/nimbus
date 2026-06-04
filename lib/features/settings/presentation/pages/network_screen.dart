import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../portfolio/data/rpc_endpoints.dart';
import '../../../portfolio/presentation/providers/network_cluster_provider.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/domain/entities/network_cluster.dart';
import '../widgets/settings_scaffold.dart';
import '../widgets/settings_section.dart';

/// Network environment picker. Choosing a cluster repoints every chain's RPC at
/// that environment, so balances (and later transactions) target Mainnet,
/// Testnet, or Devnet. The endpoints list shows exactly where each chain will
/// connect for the current choice.
class NetworkScreen extends ConsumerWidget {
  const NetworkScreen({super.key});

  static const _endpoints = RpcEndpoints();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cluster = ref.watch(networkClusterProvider);

    return SettingsScaffold(
      title: 'Network',
      intro: 'Choose the environment every chain connects to. Devnet and '
          'Testnet are for development — their coins come from free faucets and '
          'have no real value.',
      children: [
        for (final c in NetworkCluster.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ClusterOption(
              cluster: c,
              selected: c == cluster,
              onTap: () =>
                  ref.read(networkClusterProvider.notifier).set(c),
            ),
          ),
        const SizedBox(height: 8),
        SettingsSection(
          title: 'Endpoints',
          children: [
            for (final n in Network.values)
              _EndpointRow(network: n, cluster: cluster),
          ],
        ),
      ],
    );
  }
}

class _ClusterOption extends StatelessWidget {
  const _ClusterOption({
    required this.cluster,
    required this.selected,
    required this.onTap,
  });

  final NetworkCluster cluster;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NB.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? NB.orange : NB.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cluster.label,
                      style: NB.font(16, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(cluster.blurb, style: NB.font(13, color: NB.text2)),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? NB.orange : Colors.transparent,
                border:
                    selected ? null : Border.all(color: NB.surface3, width: 2),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _EndpointRow extends StatelessWidget {
  const _EndpointRow({required this.network, required this.cluster});
  final Network network;
  final NetworkCluster cluster;

  @override
  Widget build(BuildContext context) {
    final host = Uri.parse(NetworkScreen._endpoints.urlFor(network, cluster)).host;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CoinLogo(network: network, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(network.displayName,
                style: NB.font(15, weight: FontWeight.w600)),
          ),
          Flexible(
            child: Text(host,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: NB.font(12.5, color: NB.text3)),
          ),
        ],
      ),
    );
  }
}
