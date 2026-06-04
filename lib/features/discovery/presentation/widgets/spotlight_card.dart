import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../data/dapp_catalog.dart';
import 'dapp_logo.dart';

/// A featured dApp card in the Spotlight carousel: a solid brand-dark fill with
/// a soft accent glow and the dApp's own logo (faded large as a backdrop, crisp
/// as the icon), plus a chain badge, name, and category.
class SpotlightCard extends StatelessWidget {
  const SpotlightCard({super.key, required this.dapp, required this.onOpen});

  final Dapp dapp;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final base = dapp.gradient?.last ?? NB.surface;
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 232,
        height: 142,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Faded logo backdrop bleeding off the right edge.
            Positioned(
              right: -22,
              top: 18,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.12,
                  child: Image.network(
                    dapp.logoUrl,
                    width: 124,
                    height: 124,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            // Soft accent glow.
            Positioned(
              top: -42,
              right: -34,
              child: IgnorePointer(
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        dapp.accent.withValues(alpha: 0.35),
                        dapp.accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DappLogo(dapp: dapp, size: 44, radius: 13),
                      _chainBadge(),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dapp.name,
                          style: NB.font(18.5,
                              weight: FontWeight.w800, letterSpacing: -0.4)),
                      const SizedBox(height: 2),
                      Text(dapp.category,
                          style: NB.font(12,
                              weight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chainBadge() {
    final network = Network.fromId(dapp.chainId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CoinLogo(network: network, size: 14),
          const SizedBox(width: 6),
          Text(network.displayName,
              style: NB.font(11, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
