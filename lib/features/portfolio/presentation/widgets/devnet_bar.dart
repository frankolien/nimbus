import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../transfer/data/solana_send_service.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../providers/network_cluster_provider.dart';
import '../providers/portfolio_provider.dart';

/// Shown only off-mainnet: a pill flagging the active environment plus a faucet
/// button that airdrops devnet/testnet SOL to the active account, so the receive
/// flow can be tested end-to-end without leaving the app. Renders nothing on
/// mainnet.
class DevnetBar extends ConsumerStatefulWidget {
  const DevnetBar({super.key});

  @override
  ConsumerState<DevnetBar> createState() => _DevnetBarState();
}

class _DevnetBarState extends ConsumerState<DevnetBar> {
  final _solana = SolanaSendService();
  bool _busy = false;

  Future<void> _airdrop() async {
    final cluster = ref.read(networkClusterProvider);
    final address = ref
        .read(walletSessionProvider)
        .activeAccount
        ?.account(ChainFamily.solana)
        ?.address;
    if (address == null) return;

    setState(() => _busy = true);
    try {
      await _solana.requestAirdrop(address: address, cluster: cluster);
      if (!mounted) return;
      _toast('Airdrop requested — arriving shortly');
      // Give the cluster a moment to finalize, then pull fresh balances.
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) ref.read(portfolioProvider.notifier).refresh();
      });
    } catch (e) {
      if (mounted) {
        _toast(e is SolanaRpcException
            ? 'Airdrop failed: ${e.message}'
            : 'Airdrop failed — faucet busy, try again');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NB.surface2,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: NB.font(13, color: NB.text)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cluster = ref.watch(networkClusterProvider);
    if (cluster.isMainnet) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          _pill(cluster.label),
          const Spacer(),
          //_airdropButton(),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
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
            decoration:
                const BoxDecoration(color: NB.orange, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(label,
              style: NB.font(12, weight: FontWeight.w700, color: NB.orangeHi)),
        ],
      ),
    );
  }

  /*Widget _airdropButton() {
    return GestureDetector(
      onTap: _busy ? null : _airdrop,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: _busy ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: NB.borderHi),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop_outlined, size: 14, color: NB.text2),
              const SizedBox(width: 6),
              Text(_busy ? 'Requesting…' : 'Airdrop SOL',
                  style:
                      NB.font(12, weight: FontWeight.w700, color: NB.text)),
            ],
          ),
        ),
      ),
    );
  }*/
}
