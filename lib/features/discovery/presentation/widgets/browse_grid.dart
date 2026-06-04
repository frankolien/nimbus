import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../data/dapp_catalog.dart';

/// The "Browse" row of category shortcuts (Swap, NFTs, Stake, …) — tinted icon
/// tiles with a label underneath.
class BrowseGrid extends StatelessWidget {
  const BrowseGrid({super.key, required this.onTap});

  final ValueChanged<BrowseCategory> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final c in browseCategories)
          GestureDetector(
            onTap: () => onTap(c),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: c.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Icon(c.icon, size: 19, color: c.accent),
                ),
                const SizedBox(height: 6),
                Text(c.label, style: NB.font(10, color: NB.text2)),
              ],
            ),
          ),
      ],
    );
  }
}
