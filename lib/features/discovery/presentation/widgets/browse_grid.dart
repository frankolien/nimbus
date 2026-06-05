import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../data/dapp_catalog.dart';

/// The "Browse" row of category shortcuts (Swap, NFTs, Stake, …) — each a small
/// looping Lottie on a uniform tile with a label underneath.
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: NB.surface2,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Lottie.asset(
                      c.lottie,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(c.icon, size: 21, color: NB.text),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(c.label, style: NB.font(10.5, color: NB.text2)),
              ],
            ),
          ),
      ],
    );
  }
}
