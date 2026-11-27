import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../providers/network_cluster_provider.dart';

/// A pill naming the active cluster, shown whenever it isn't mainnet so test
/// funds are never mistaken for real ones. Renders nothing on mainnet.
class DevnetBar extends ConsumerWidget {
  const DevnetBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cluster = ref.watch(networkClusterProvider);
    if (cluster.isMainnet) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: NB.orange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: NB.orange, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text('Solana ${cluster.label}',
                    style: NB.font(12,
                        weight: FontWeight.w700, color: NB.orangeHi)),
              ],
            ),
          ),
          const Spacer(),
          Text('Test funds, no real value',
              style: NB.font(12, color: NB.text3)),
        ],
      ),
    );
  }
}
