import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../portfolio/presentation/providers/network_cluster_provider.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../../data/evm_send_service.dart';
import '../../data/solana_send_service.dart';
import '../providers/address_providers.dart';
import 'slide_to_confirm.dart';

/// Review + confirm a transfer. Slides to sign and broadcast; returns the tx
/// hash on success (and records the recipient as recent), or null if dismissed.
Future<String?> showReviewTransferSheet(
  BuildContext context, {
  required Network network,
  required String recipient,
  required String amountString,
  required double usdValue,
  required double feeSol,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: NB.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ReviewSheet(
      network: network,
      recipient: recipient,
      amountString: amountString,
      usdValue: usdValue,
      feeSol: feeSol,
    ),
  );
}

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({
    required this.network,
    required this.recipient,
    required this.amountString,
    required this.usdValue,
    required this.feeSol,
  });

  final Network network;
  final String recipient;
  final String amountString;
  final double usdValue;
  final double feeSol;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  final _solana = SolanaSendService();
  final _evm = EvmSendService();
  bool _sending = false;
  String? _error;

  bool get _isSolana => widget.network.family == ChainFamily.solana;
  double get _amount => double.tryParse(widget.amountString) ?? 0;
  String get _symbol => widget.network.nativeSymbol;

  Future<void> _confirm() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final index = ref.read(walletSessionProvider).activeAccountIndex;
      final cluster = ref.read(networkClusterProvider);
      final vault = ref.read(walletVaultProvider);

      final String hash;
      if (_isSolana) {
        final signer = vault.signingKey(ChainFamily.solana, index);
        hash = await _solana.sendNative(
          fromAddress: signer.address,
          privateKeyBytes: signer.privateKeyBytes,
          toAddress: widget.recipient,
          amountSol: widget.amountString,
          cluster: cluster,
        );
      } else {
        final signer = vault.signingKey(ChainFamily.evm, index);
        hash = await _evm.sendNative(
          network: widget.network,
          privateKeyHex: signer.privateKeyHex,
          toAddress: widget.recipient,
          amountEther: widget.amountString,
          cluster: cluster,
        );
      }

      await ref
          .read(recentRecipientsProvider.notifier)
          .record(widget.recipient, widget.network.family);
      ref.read(portfolioProvider.notifier).refresh();
      if (mounted) Navigator.of(context).pop(hash);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _humanize(e);
          _sending = false;
        });
      }
    }
  }

  String _humanize(Object e) {
    if (e is SolanaRpcException) {
      final m = e.message.toLowerCase();
      if (m.contains('insufficient') || m.contains('debit')) {
        return 'Insufficient SOL for amount + fees.';
      }
      return e.message;
    }
    if (e.toString().contains('insufficient funds')) {
      return 'Insufficient funds for amount + gas fees.';
    }
    return 'Could not send. Check the amount and try again.';
  }

  @override
  Widget build(BuildContext context) {
    final cluster = ref.watch(networkClusterProvider);
    final feeLabel =
        _isSolana ? '${Fmt.tokenAmount(widget.feeSol)} SOL' : 'Gas at send';
    final totalLabel = _isSolana
        ? '${Fmt.tokenAmount(_amount + widget.feeSol)} SOL'
        : '${Fmt.tokenAmount(_amount)} $_symbol + gas';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Review transfer',
                  style: NB.font(18, weight: FontWeight.w800)),
              const Spacer(),
              GestureDetector(
                onTap: _sending ? null : () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: NB.text2),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Center(
            child: Column(
              children: [
                Text('You are sending', style: NB.font(13.5, color: NB.text2)),
                const SizedBox(height: 8),
                Text('${Fmt.tokenAmount(_amount)} $_symbol',
                    style: NB.font(30, weight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(Fmt.usd(widget.usdValue),
                    style: NB.font(14.5, color: NB.text2)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: NB.surface2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _row('Recipient', Fmt.address(widget.recipient)),
                _divider(),
                _row('Network', '${widget.network.displayName} · ${cluster.label}'),
                _divider(),
                _row('Network fee', feeLabel),
                _divider(),
                _row('Total', totalLabel, strong: true),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: NB.font(13, color: NB.red)),
          ],
          const SizedBox(height: 22),
          SlideToConfirm(
            label: 'Slide to confirm',
            busy: _sending,
            busyLabel: 'Confirming…',
            onConfirmed: _confirm,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool strong = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(label, style: NB.font(13.5, color: NB.text2)),
            const Spacer(),
            Text(value,
                style: NB.font(13.5,
                    weight: strong ? FontWeight.w800 : FontWeight.w600,
                    color: NB.text)),
          ],
        ),
      );

  Widget _divider() => const Divider(color: NB.border, height: 1);
}
