import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../portfolio/presentation/providers/network_cluster_provider.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../data/evm_send_service.dart';
import '../../data/solana_send_service.dart';
import '../providers/address_providers.dart';
import '../widgets/recipient_tile.dart';
import '../widgets/save_address_sheet.dart';
import '../widgets/transfer_header.dart';
import 'address_book_screen.dart';
import 'send_amount_screen.dart';

/// Step 1 of the send flow: choose the recipient. Paste or type an address,
/// or tap a recent / saved one. The send targets the active cluster, so the
/// same flow works on Mainnet and Devnet/Testnet.
class SendRecipientScreen extends ConsumerStatefulWidget {
  const SendRecipientScreen({super.key, required this.network});

  final Network network;

  @override
  ConsumerState<SendRecipientScreen> createState() =>
      _SendRecipientScreenState();
}

class _SendRecipientScreenState extends ConsumerState<SendRecipientScreen> {
  final _to = TextEditingController();

  ChainFamily get _family => widget.network.family;

  bool _isValid(String a) => _family == ChainFamily.solana
      ? SolanaSendService.isValidAddress(a)
      : EvmSendService.isValidAddress(a);

  bool get _canContinue => _isValid(_to.text.trim());

  @override
  void dispose() {
    _to.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) {
      _to.text = text;
      setState(() {});
    }
  }

  void _select(String address) {
    _to.text = address;
    setState(() {});
  }

  void _continue() {
    if (!_canContinue) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SendAmountScreen(
        network: widget.network,
        recipient: _to.text.trim(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cluster = ref.watch(networkClusterProvider);
    final recents = ref
        .watch(recentRecipientsProvider)
        .where((r) => r.family == _family)
        .toList();
    final saved =
        ref.watch(savedAddressesProvider).where((s) => s.family == _family).toList();

    String? savedLabel(String address) {
      for (final s in saved) {
        if (s.address == address) return s.label;
      }
      return null;
    }

    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Column(
          children: [
            TransferHeader(
              title: 'Send ${widget.network.nativeSymbol}',
              trailing: cluster.isMainnet ? null : _ClusterDot(label: cluster.label),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _toField(),
                  if (_canContinue) ...[
                    const SizedBox(height: 14),
                    _addressFound(),
                  ],
                  if (recents.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    _sectionHead('Recent transfers',
                        action: 'View all',
                        onAction: () => _openBook()),
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
              onChanged: (_) => setState(() {}),
              style: NB.font(15, color: NB.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Recipient address',
                hintStyle: NB.font(15, color: NB.text3),
              ),
            ),
          ),
          if (empty)
            TextButton(
              onPressed: _paste,
              child: Text('Paste',
                  style: NB.font(14, weight: FontWeight.w700, color: NB.orange)),
            )
          else
            IconButton(
              onPressed: () => setState(_to.clear),
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
                Text('Address found',
                    style: NB.font(14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(Fmt.address(_to.text.trim()),
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
              child: Icon(Icons.bookmark_add_outlined, size: 20, color: NB.text2),
            ),
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
                style: NB.font(13.5, weight: FontWeight.w700, color: NB.orange)),
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
