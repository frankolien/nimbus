import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../wallet/domain/entities/network.dart';
import '../widgets/settings_scaffold.dart';

/// Shows the network the wallet uses. The Xend backend runs on Solana devnet
/// only, so there is nothing to switch here yet.
class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Network',
      intro: 'Nimbus runs on Solana Devnet. Devnet coins come from free faucets '
          'and have no real value. Mainnet support is coming.',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NB.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: NB.orange, width: 1.5),
          ),
          child: Row(
            children: [
              const CoinLogo(network: Network.solana, size: 38),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Solana Devnet',
                        style: NB.font(16, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('Developer network with free faucets',
                        style: NB.font(13, color: NB.text2)),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: NB.orange,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
