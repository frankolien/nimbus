import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../onboarding/presentation/widgets/nimbus_widgets.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/review_transfer_sheet.dart';
import '../widgets/transfer_header.dart';
import 'send_success_screen.dart';

/// Step 2 of the send flow: enter the amount with a custom keypad. Toggle
/// between the asset amount and its USD value; "Max" fills the spendable
/// balance (minus the network fee on native chains).
class SendAmountScreen extends ConsumerStatefulWidget {
  const SendAmountScreen({
    super.key,
    required this.network,
    required this.recipient,
  });

  final Network network;
  final String recipient;

  @override
  ConsumerState<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends ConsumerState<SendAmountScreen> {
  String _input = '';
  bool _fiat = false;
  String? _error;

  String get _symbol => widget.network.nativeSymbol;

  // Solana's base fee is 5000 lamports/signature; EVM gas is paid separately.
  double get _feeNative =>
      widget.network.family == ChainFamily.solana ? 0.000005 : 0;

  double _balance() {
    for (final e in ref.read(portfolioProvider).valueOrNull?.entries ??
        const []) {
      if (e.network == widget.network) return e.amount ?? 0;
    }
    return 0;
  }

  double? _price() {
    for (final e in ref.read(portfolioProvider).valueOrNull?.entries ??
        const []) {
      if (e.network == widget.network) return e.usdPrice;
    }
    return null;
  }

  double get _entered => double.tryParse(_input.isEmpty ? '0' : _input) ?? 0;

  double get _nativeAmount {
    final p = _price() ?? 0;
    return _fiat ? (p > 0 ? _entered / p : 0) : _entered;
  }

  double get _usdAmount {
    final p = _price() ?? 0;
    return _fiat ? _entered : _entered * p;
  }

  double get _spendable {
    final s = _balance() - _feeNative;
    return s > 0 ? s : 0;
  }

  bool get _canReview =>
      _nativeAmount > 1e-12 && _nativeAmount <= _spendable + 1e-9;

  /// The exact decimal string to broadcast. In asset mode that's the typed
  /// value; in fiat mode it's the converted amount at the asset's precision.
  String get _amountString {
    if (!_fiat) return _input.isEmpty ? '0' : _input;
    final dec = widget.network.nativeDecimals.clamp(0, 18);
    return _trimZeros(_nativeAmount.toStringAsFixed(dec));
  }

  static String _trimZeros(String s) => s.contains('.')
      ? s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
      : s;

  void _key(String k) {
    setState(() {
      _error = null;
      if (k == '.') {
        if (_input.contains('.')) return;
        if (_input.isEmpty) {
          _input = '0.';
          return;
        }
      }
      if (_input.replaceAll('.', '').length >= 12) return;
      _input += k;
    });
  }

  void _backspace() => setState(() {
        _error = null;
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      });

  void _max() => setState(() {
        _fiat = false;
        _input = _trimZeros(
            _spendable.toStringAsFixed(widget.network.nativeDecimals.clamp(0, 9)));
      });

  void _flip() {
    final p = _price();
    if (p == null || p == 0) return;
    setState(() {
      if (_fiat) {
        _input = _trimZeros(_nativeAmount
            .toStringAsFixed(widget.network.nativeDecimals.clamp(0, 9)));
        _fiat = false;
      } else {
        _input = _usdAmount.toStringAsFixed(2);
        _fiat = true;
      }
      if (_entered == 0) _input = '';
    });
  }

  Future<void> _review() async {
    if (!_canReview) {
      setState(() => _error = 'Enter an amount up to your balance.');
      return;
    }
    final amountLabel = '${Fmt.tokenAmount(_nativeAmount)} $_symbol';
    final hash = await showReviewTransferSheet(
      context,
      network: widget.network,
      recipient: widget.recipient,
      amountString: _amountString,
      usdValue: _usdAmount,
      feeSol: _feeNative,
    );
    if (hash != null && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => SendSuccessScreen(
            network: widget.network,
            amountLabel: amountLabel,
            hash: hash,
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = _balance();
    final hasPrice = (_price() ?? 0) > 0;
    final primary = _fiat
        ? '\$${_input.isEmpty ? '0' : _input}'
        : '${_input.isEmpty ? '0' : _input} $_symbol';
    final secondary = _fiat
        ? '≈ ${Fmt.tokenAmount(_nativeAmount)} $_symbol'
        : (hasPrice ? '≈ ${Fmt.usd(_usdAmount)}' : '');

    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TransferHeader(title: 'Send $_symbol'),
            Center(child: _toPill()),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Available', style: NB.font(12.5, color: NB.text2)),
                const SizedBox(width: 6),
                Text('${Fmt.tokenAmount(balance)} $_symbol',
                    style: NB.font(12.5, weight: FontWeight.w700)),
                const SizedBox(width: 8),
                _maxChip(),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(primary,
                        style: NB.font(40,
                            weight: FontWeight.w700, letterSpacing: -1)),
                  ),
                ),
                if (hasPrice) ...[
                  const SizedBox(width: 12),
                  _flipButton(),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Center(child: Text(secondary, style: NB.font(14, color: NB.text2))),
            const Spacer(),
            if (_error != null) ...[
              Center(child: Text(_error!, style: NB.font(13, color: NB.red))),
              const SizedBox(height: 12),
            ],
            NumericKeypad(onKey: _key, onBackspace: _backspace),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:
                  NbButton(label: 'Confirm', enabled: _canReview, onTap: _review),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _toPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: NB.surface2,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 15, color: NB.text2),
          const SizedBox(width: 8),
          Text('To ${Fmt.address(widget.recipient)}',
              style: NB.font(13, weight: FontWeight.w600, color: NB.text)),
        ],
      ),
    );
  }

  Widget _maxChip() => GestureDetector(
        onTap: _max,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: NB.orange.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Max',
              style: NB.font(11.5, weight: FontWeight.w800, color: NB.orange)),
        ),
      );

  Widget _flipButton() => GestureDetector(
        onTap: _flip,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 40,
          height: 40,
          decoration:
              const BoxDecoration(color: NB.surface2, shape: BoxShape.circle),
          child: const Icon(Icons.swap_vert, size: 20, color: NB.text),
        ),
      );
}
