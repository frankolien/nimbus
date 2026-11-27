import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xend/xend.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../onboarding/presentation/widgets/nimbus_widgets.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';

/// Final step: the transfer was submitted. Shows its live status from
/// `XendWallet.watch` (pending, confirmed, finalized) and links to the devnet
/// explorer. "Done" returns to the wallet.
class SendSuccessScreen extends ConsumerStatefulWidget {
  const SendSuccessScreen({
    super.key,
    required this.network,
    required this.amountLabel,
    required this.hash,
  });

  final Network network;
  final String amountLabel;

  /// The transaction signature, which is also Xend's handle id.
  final String hash;

  @override
  ConsumerState<SendSuccessScreen> createState() => _SendSuccessScreenState();
}

class _SendSuccessScreenState extends ConsumerState<SendSuccessScreen> {
  StreamSubscription<TxStatus>? _sub;
  TxStatus? _status;
  bool _watchFailed = false;

  // Xend's backend runs on devnet.
  String get _explorerUrl =>
      'https://explorer.solana.com/tx/${widget.hash}?cluster=devnet';

  @override
  void initState() {
    super.initState();
    final wallet = ref.read(xendWalletProvider);
    if (wallet == null) return;
    _sub = wallet.watch(TxHandle(widget.hash)).listen(
          (s) => setState(() => _status = s),
          onError: (_) => setState(() => _watchFailed = true),
        );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  ({String title, String body, IconData icon, Color color}) get _view {
    final s = _status;
    if (s != null && s.isFailed) {
      return (
        title: 'Transfer failed',
        body: 'The network didn\'t accept this transfer of '
            '${widget.amountLabel}. Your funds were not sent.',
        icon: Icons.close_rounded,
        color: NB.red,
      );
    }
    if (s?.state == 'finalized') {
      return (
        title: 'Successful!',
        body: 'You sent ${widget.amountLabel}. The transfer is final.',
        icon: Icons.check_rounded,
        color: NB.green,
      );
    }
    if (s?.state == 'confirmed') {
      return (
        title: 'Successful!',
        body: 'You sent ${widget.amountLabel}. It\'s confirmed and will be '
            'final in a few seconds.',
        icon: Icons.check_rounded,
        color: NB.green,
      );
    }
    return (
      title: 'Sending…',
      body: 'Your transfer of ${widget.amountLabel} was submitted and is '
          'waiting for the network to confirm it.',
      icon: Icons.schedule_rounded,
      color: NB.orange,
    );
  }

  String get _statusLabel {
    if (_watchFailed) return 'Status unavailable, check the explorer';
    return switch (_status?.state) {
      'finalized' => 'Finalized',
      'confirmed' => 'Confirmed',
      'failed' => 'Failed',
      _ => 'Pending',
    };
  }

  @override
  Widget build(BuildContext context) {
    final v = _view;
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
                  color: v.color.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: v.color.withValues(alpha: 0.18),
                  ),
                  child: Icon(v.icon, color: v.color, size: 40),
                ),
              ),
              const SizedBox(height: 26),
              Text(v.title, style: NB.font(23, weight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(
                v.body,
                textAlign: TextAlign.center,
                style: NB.font(14.5, color: NB.text2, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: NB.surface2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$_statusLabel · Devnet',
                    style: NB.font(12.5,
                        weight: FontWeight.w700, color: NB.text2)),
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
                onTap: () => launchUrl(Uri.parse(_explorerUrl),
                    mode: LaunchMode.externalApplication),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
