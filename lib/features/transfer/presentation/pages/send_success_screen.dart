import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../onboarding/presentation/widgets/nimbus_widgets.dart';
import '../../../portfolio/presentation/providers/network_cluster_provider.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/domain/entities/network_cluster.dart';

/// Final step: confirmation that the transfer was broadcast, with a link to the
/// block explorer. "Done" returns to the wallet.
class SendSuccessScreen extends ConsumerWidget {
  const SendSuccessScreen({
    super.key,
    required this.network,
    required this.amountLabel,
    required this.hash,
  });

  final Network network;
  final String amountLabel;
  final String hash;

  String _explorerUrl(NetworkCluster cluster) {
    if (network.family == ChainFamily.solana) {
      final q = cluster.isMainnet ? '' : '?cluster=${cluster.id}';
      return 'https://solscan.io/tx/$hash$q';
    }
    return '${network.explorerBaseUrl}/tx/$hash';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cluster = ref.read(networkClusterProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NB.green.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NB.green.withValues(alpha: 0.18),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: NB.green, size: 40),
                ),
              ),
              const SizedBox(height: 26),
              Text('Successful!', style: NB.font(23, weight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(
                'You successfully sent $amountLabel. It will be deposited in '
                'the recipient wallet shortly.',
                textAlign: TextAlign.center,
                style: NB.font(14.5, color: NB.text2, height: 1.5),
              ),
              const Spacer(),
              NbButton(
                label: 'Done',
                onTap: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
              const SizedBox(height: 12),
              NbButton(
                label: 'View on explorer',
                variant: NbBtnVariant.outline,
                onTap: () => launchUrl(Uri.parse(_explorerUrl(cluster)),
                    mode: LaunchMode.externalApplication),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
