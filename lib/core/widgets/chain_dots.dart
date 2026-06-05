import 'package:flutter/material.dart';

import '../../features/wallet/domain/entities/chain_family.dart';
import '../../features/wallet/domain/entities/network.dart';
import '../theme/nimbus_theme.dart';
import 'coin_logo.dart';

/// A row of overlapping chain logos with a thin ring, used to show at a glance
/// which chains an account spans. Uses real coin artwork via [CoinLogo].
class ChainDots extends StatelessWidget {
  const ChainDots({
    super.key,
    required this.networks,
    this.size = 18,
    this.ring = NB.bg,
  });

  final List<Network> networks;
  final double size;

  /// Color of the ring separating overlapping dots (usually the backdrop).
  final Color ring;

  /// The network whose logo best represents [family] in compact UI.
  static Network representative(ChainFamily family) => switch (family) {
        ChainFamily.evm => Network.ethereum,
        ChainFamily.solana => Network.solana,
        ChainFamily.bitcoin => Network.bitcoin,
        ChainFamily.sui => Network.sui,
      };

  @override
  Widget build(BuildContext context) {
    if (networks.isEmpty) return const SizedBox.shrink();
    const ringWidth = 1.5;
    final dot = size + ringWidth * 2; // full diameter including the ring
    final step = dot * 0.64; // leading edge of each successive dot
    final width = dot + step * (networks.length - 1);

    return SizedBox(
      width: width,
      height: dot,
      child: Stack(
        children: [
          for (var i = 0; i < networks.length; i++)
            Positioned(
              left: step * i,
              child: Container(
                padding: const EdgeInsets.all(ringWidth),
                decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
                child: CoinLogo(network: networks[i], size: size),
              ),
            ),
        ],
      ),
    );
  }
}
