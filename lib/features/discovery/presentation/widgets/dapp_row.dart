import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../data/dapp_catalog.dart';
import 'dapp_logo.dart';

/// A "Popular apps" row: monogram tile with a chain badge, name + category, and
/// an Open button that launches the dApp.
class DappRow extends StatelessWidget {
  const DappRow({super.key, required this.dapp, required this.onOpen});

  final Dapp dapp;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: NB.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NB.border),
        ),
        child: Row(
          children: [
            _icon(),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dapp.name,
                      style: NB.font(14, weight: FontWeight.w700)),
                  const SizedBox(height: 1),
                  Text(dapp.category, style: NB.font(11.5, color: NB.text2)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: NB.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Open',
                  style: NB.font(12, weight: FontWeight.w700, color: NB.orange)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DappLogo(dapp: dapp, size: 40, radius: 11),
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration:
                  const BoxDecoration(color: NB.bg, shape: BoxShape.circle),
              child: CoinLogo(network: Network.fromId(dapp.chainId), size: 15),
            ),
          ),
        ],
      ),
    );
  }
}
