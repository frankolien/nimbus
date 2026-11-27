import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xend/xend.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../domain/solana_recipient.dart';
import '../providers/address_providers.dart';
import '../widgets/recipient_tile.dart';
import '../widgets/save_address_sheet.dart';
import '../widgets/transfer_header.dart';
import 'address_book_screen.dart';
import 'send_amount_screen.dart';

/// Step 1 of the send flow: choose the recipient. Paste or type a Solana
/// address or a `.sol` name, or tap a recent / saved one. Sending goes through
/// Xend, which is Solana-only for now, so other networks show "coming soon".
class SendRecipientScreen extends ConsumerStatefulWidget {
  const SendRecipientScreen({super.key, required this.network});

  final Network network;

  @override
  ConsumerState<SendRecipientScreen> createState() =>
      _SendRecipientScreenState();
}

class _SendRecipientScreenState extends ConsumerState<SendRecipientScreen> {
  final _to = TextEditingController();
  Timer? _debounce;

  // Name lookup state for `.sol` input. [_resolvedFor] is the name the result
  // belongs to, so a stale lookup never unlocks a newer input.
  String? _resolvedFor;
  String? _resolved;
  bool _resolving = false;
  String? _resolveError;

  ChainFamily get _family => widget.network.family;
  bool get _supported => _family == ChainFamily.solana;

  // Names are case-insensitive; send them lowercased.
  String get _input {
    final t = _to.text.trim();
    return isSolName(t) ? t.toLowerCase() : t;
  }
  bool get _isName => isSolName(_input);

  bool get _canContinue {
    if (isSolanaAddress(_input)) return true;
    return _isName && _resolvedFor == _input && _resolved != null;
  }

  /// The address the review sheet should expect in the built transaction.
  String get _expectedAddress => _isName ? _resolved! : _input;

  @override
  void dispose() {
    _debounce?.cancel();
    _to.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    _debounce?.cancel();
    if (!_isName) return;
    final name = _input;
    if (name == _resolvedFor) return;
    setState(() {
      _resolving = true;
      _resolveError = null;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () => _resolve(name));
  }

  Future<void> _resolve(String name) async {
    String? address;
    String? error;
    try {
      address = await XendWallet.resolveName(name);
      if (!isSolanaAddress(address)) {
        address = null;
        error = 'That name doesn\'t point to a valid address.';
      }
    } on InvalidRecipient {
      error = 'No wallet is registered to $name.';
    } on XendError {
      error = 'Couldn\'t look up $name. Check your connection.';
    } catch (_) {
      error = 'Couldn\'t look up $name.';
    }
    if (!mounted || name != _input) return;
    setState(() {
      _resolving = false;
      _resolvedFor = name;
      _resolved = address;
      _resolveError = error;
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) {
      _to.text = text;
      _onChanged();
    }
  }

  void _select(String address) {
    _to.text = address;
    _onChanged();
  }

  void _continue() {
    if (!_canContinue) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SendAmountScreen(
        network: widget.network,
        recipient: _input,
        recipientAddress: _expectedAddress,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) return _ComingSoon(network: widget.network);
    final recents = ref
        .watch(recentRecipientsProvider)
        .where((r) => r.family == _family)
        .toList();
    final saved = ref
        .watch(savedAddressesProvider)
        .where((s) => s.family == _family)
        .toList();

    String? savedLabel(String address) {
      for (final s in saved) {
        if (s.address == address) return s.label;
      }
      return null;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            TransferHeader(
              title: 'Send ${widget.network.nativeSymbol}',
              trailing: const _ClusterDot(label: 'Devnet'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _toField(),
                  if (_canContinue) ...[
                    const SizedBox(height: 14),
                    _addressFound(),
                  ] else if (_isName &&
                      (_resolving || _resolveError != null)) ...[
                    const SizedBox(height: 14),
                    _nameStatus(),
                  ],
                  if (recents.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    _sectionHead('Recent transfers',
                        action: 'View all', onAction: () => _openBook()),
                    for (final r in recents.take(5))
                      RecipientTile(
                        title: savedLabel(r.address) ?? Fmt.address(r.address),
                        subtitle: 'Recent',
                        onTap: () => _select(r.address),
                      ),
                  ],
                  const SizedBox(height: 26),
                  _sectionHead('My saved addresses',
                      action: 'Add',
                      onAction: () => showSaveAddressSheet(context,
                          family: _family,
                          prefillAddress:
                              _canContinue ? _to.text.trim() : null)),
                  if (saved.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No saved addresses yet.',
                          style: NB.font(13.5, color: NB.text3)),
                    )
                  else
                    for (final s in saved)
                      RecipientTile(
                        title: s.label,
                        subtitle: Fmt.address(s.address),
                        onTap: () => _select(s.address),
                      ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _continueButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toField() {
    final empty = _to.text.isEmpty;
    return Container(
      decoration: BoxDecoration(
        color: NB.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _canContinue ? NB.green.withValues(alpha: 0.5) : NB.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _to,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => _onChanged(),
              style: NB.font(15, color: NB.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Address or .sol name',
                hintStyle: NB.font(15, color: NB.text3),
              ),
            ),
          ),
          if (empty)
            TextButton(
              onPressed: _paste,
              child: Text('Paste',
                  style:
                      NB.font(14, weight: FontWeight.w700, color: NB.orange)),
            )
          else
            IconButton(
              onPressed: () {
                _to.clear();
                _onChanged();
              },
              icon: const Icon(Icons.close, size: 18, color: NB.text3),
            ),
        ],
      ),
    );
  }

  Widget _addressFound() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: NB.green.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20, color: NB.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isName ? _input : 'Address found',
                    style: NB.font(14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(Fmt.address(_expectedAddress),
                    style: NB.font(12.5, color: NB.text2)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showSaveAddressSheet(context,
                family: _family, prefillAddress: _to.text.trim()),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child:
                  Icon(Icons.bookmark_add_outlined, size: 20, color: NB.text2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameStatus() {
    final error = _resolveError;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: (error == null ? NB.surface2 : NB.red.withValues(alpha: 0.10)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (error == null)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: NB.text2),
            )
          else
            const Icon(Icons.error_outline, size: 20, color: NB.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(error ?? 'Looking up $_input…',
                style: NB.font(13.5, color: error == null ? NB.text2 : NB.red)),
          ),
        ],
      ),
    );
  }

  void _openBook() => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => AddressBookScreen(family: _family),
      ));

  Widget _sectionHead(String title,
      {required String action, required VoidCallback onAction}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(title, style: NB.font(15, weight: FontWeight.w800)),
          const Spacer(),
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(action,
                style:
                    NB.font(13.5, weight: FontWeight.w700, color: NB.orange)),
          ),
        ],
      ),
    );
  }

  Widget _continueButton() {
    final enabled = _canContinue;
    return GestureDetector(
      onTap: enabled ? _continue : null,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? NB.orange : NB.surface2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text('Continue',
            style: NB.font(16,
                weight: FontWeight.w800,
                color: enabled ? Colors.white : NB.text3)),
      ),
    );
  }
}

class _ClusterDot extends StatelessWidget {
  const _ClusterDot({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: NB.orange.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: NB.font(11.5, weight: FontWeight.w700, color: NB.orangeHi)),
    );
  }
}

/// Shown for networks Xend can't send on yet.
class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.network});
  final Network network;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            TransferHeader(title: 'Send ${network.nativeSymbol}'),
            const Spacer(),
            const Icon(Icons.schedule, size: 44, color: NB.text3),
            const SizedBox(height: 16),
            Text('${network.displayName} sending is coming soon',
                style: NB.font(17, weight: FontWeight.w800)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'For now you can send SOL on Solana.',
                textAlign: TextAlign.center,
                style: NB.font(14, color: NB.text2, height: 1.5),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
