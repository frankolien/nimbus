import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../wallet/domain/entities/network.dart';

/// Horizontally scrolling chain filters. 'all' shows everything; the rest carry
/// a real chain logo and narrow the lists to that chain.
class ChainFilterChips extends StatelessWidget {
  const ChainFilterChips({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  static const _chains = [
    'all',
    'solana',
    'ethereum',
    'bitcoin',
    'base',
    'polygon',
    'sui',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _chains.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final id = _chains[i];
          final on = id == selected;
          final isAll = id == 'all';
          final label = isAll ? 'All Chains' : Network.fromId(id).displayName;
          return GestureDetector(
            onTap: () => onSelect(id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.only(left: isAll ? 13 : 6, right: 13),
              decoration: BoxDecoration(
                color: on ? Colors.white : NB.surface2,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  if (!isAll) ...[
                    CoinLogo(network: Network.fromId(id), size: 18),
                    const SizedBox(width: 6),
                  ],
                  Text(label,
                      style: NB.font(12.5,
                          weight: FontWeight.w700,
                          color: on ? NB.bg : NB.text2)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
