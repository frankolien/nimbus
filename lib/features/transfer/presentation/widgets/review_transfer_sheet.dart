import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xend/xend.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../../domain/amount_units.dart';
import '../providers/address_providers.dart';
import 'slide_to_confirm.dart';

/// Review + confirm a transfer. Sliding is the user's approval; Xend then
/// checks the transaction, we check its preview against this sheet, and Face ID
/// signs it. Returns the transaction signature on success (and records the
/// recipient as recent), or null if dismissed.
Future<String?> showReviewTransferSheet(
  BuildContext context, {
  required Network network,
  required String recipient,
  required String recipientAddress,
  required BigInt amountUnits,
  required double usdValue,
  required double feeSol,
  Asset? asset,
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
      recipientAddress: recipientAddress,
      amountUnits: amountUnits,
      usdValue: usdValue,
      feeSol: feeSol,
      asset: asset,
    ),
  );
}

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({
    required this.network,
    required this.recipient,
    required this.recipientAddress,
    required this.amountUnits,
    required this.usdValue,
    required this.feeSol,
    this.asset,
  });

  final Network network;

  /// What the user entered: an address or a `.sol` name.
  final String recipient;

  /// The address shown on this sheet, which the transaction must pay.
  final String recipientAddress;
  final BigInt amountUnits;
  final double usdValue;
  final double feeSol;

  /// An SPL token, or null for native SOL.
  final Asset? asset;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  bool _sending = false;
  String? _error;

  // Set when our own preview check declines, so the resulting
  // UserCancelledAuth is reported as a block rather than a cancel.
  bool _previewMismatch = false;

  bool get _isSolana => widget.network.family == ChainFamily.solana;
  int get _decimals => widget.asset?.decimals ?? widget.network.nativeDecimals;
  String get _symbol => widget.asset?.symbol ?? widget.network.nativeSymbol;
  String get _amountLabel => fromBaseUnits(widget.amountUnits, _decimals);
  bool get _isNative => widget.asset?.mint == null;

  /// Approve only what this sheet showed: same recipient, amount and token.
  Future<bool> _checkPreview(TransferPreview p) async {
    final ok = p.recipient == widget.recipientAddress &&
        p.amount == widget.amountUnits &&
        p.mint == widget.asset?.mint;
    if (!ok) _previewMismatch = true;
    return ok;
  }

  Future<void> _confirm() async {
    final wallet = ref.read(xendWalletProvider);
    if (!_isSolana || wallet == null) {
      setState(() => _error = _isSolana
          ? 'Wallet isn\'t ready yet. Try again in a moment.'
          : '${widget.network.displayName} sending is coming soon.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
      _previewMismatch = false;
    });
    try {
      final handle = await wallet.send(
        to: widget.recipient,
        amount: widget.amountUnits,
        asset: _isNative ? null : widget.asset,
        confirm: _checkPreview,
      );

      await ref
          .read(recentRecipientsProvider.notifier)
          .record(widget.recipient, widget.network.family);
      ref.read(portfolioProvider.notifier).refresh();
      if (mounted) Navigator.of(context).pop(handle.id);
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
    if (_previewMismatch || e is TransactionMismatch) {
      return 'Blocked: the transaction didn\'t match what you approved. '
          'Nothing was sent.';
    }
    return switch (e) {
      UserCancelledAuth() => 'Face ID was cancelled. Nothing was sent.',
      InsufficientFunds() => 'Not enough $_symbol to cover this transfer.',
      InvalidRecipient() => 'That recipient isn\'t a valid Solana address.',
      NetworkError() ||
      RateLimited() =>
        'Network problem. Check your connection and try again.',
      BlockhashExpired() => 'The transfer took too long. Please try again.',
      ChainRejected() => 'The network rejected this transfer.',
      KeyInvalidated() =>
        'Face ID changed on this device, so the signing key was reset. '
            'Reopen Nimbus to restore it, then try again.',
      SecureElementError() =>
        'Face ID isn\'t available. Check your device settings.',
      XendError(:final message) => 'Could not send: $message',
      _ => 'Could not send. Check the amount and try again.',
    };
  }

  @override
  Widget build(BuildContext context) {
    // Xend's backend usually sponsors the fee; we can't know until it builds
    // the transaction, so show it as an upper bound.
    final feeLabel = 'Up to ${Fmt.tokenAmount(widget.feeSol)} SOL';
    final isName = widget.recipient != widget.recipientAddress;

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
                Text('$_amountLabel $_symbol',
                    style: NB.font(30,
                        weight: FontWeight.w800, letterSpacing: -0.5)),
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
                if (isName) ...[
                  _row('Recipient', widget.recipient),
                  _divider(),
                  _row('Address', Fmt.address(widget.recipientAddress)),
                ] else
                  _row('Recipient', Fmt.address(widget.recipientAddress)),
                _divider(),
                _row('Network', '${widget.network.displayName} · Devnet'),
                _divider(),
                _row('Network fee', feeLabel),
                _divider(),
                _row('Amount', '$_amountLabel $_symbol', strong: true),
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
