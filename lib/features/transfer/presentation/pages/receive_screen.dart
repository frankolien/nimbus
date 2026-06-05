import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/transfer_header.dart';
import 'receive_detail_screen.dart';

/// Receive funds: a list of the wallet's per-chain addresses. Each row copies
/// the address or opens its QR. EVM networks share one address, so the list is
/// one row per chain family (Solana, Ethereum & EVM, Bitcoin, Sui).
class ReceiveScreen extends ConsumerStatefulWidget {
  const ReceiveScreen({super.key});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
  static const _receivable = [
    Network.solana,
    Network.ethereum,
    Network.bitcoin,
    Network.sui,
  ];

  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _copy(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: NB.surface2,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      content: Text('Address copied', style: NB.font(13, color: NB.text)),
    ));
  }

  void _openDetail(Network network) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ReceiveDetailScreen(network: network),
      ));

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(walletSessionProvider).activeAccount;
    final q = _search.text.trim().toLowerCase();

    final rows = <({Network network, String address})>[];
    if (account != null) {
      for (final n in _receivable) {
        final address = account.account(n.family)?.address;
        if (address == null) continue;
        final matches = q.isEmpty ||
            n.displayName.toLowerCase().contains(q) ||
            n.nativeSymbol.toLowerCase().contains(q);
        if (matches) rows.add((network: n, address: address));
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const TransferHeader(title: 'Receive crypto'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: SearchField(
                controller: _search,
                hint: 'Search crypto',
                onChanged: (_) => setState(() {}),
                onClear: () => setState(_search.clear),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  for (final r in rows)
                    _AddressRow(
                      network: r.network,
                      address: r.address,
                      onTap: () => _openDetail(r.network),
                      onCopy: () => _copy(r.address),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.network,
    required this.address,
    required this.onTap,
    required this.onCopy,
  });

  final Network network;
  final String address;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: NB.surface2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CoinLogo(network: network, size: 44),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${network.displayName} address',
                      style: NB.font(15, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(Fmt.address(address),
                      style: NB.font(12.5, color: NB.text2)),
                ],
              ),
            ),
            _CircleButton(icon: Icons.qr_code_rounded, onTap: onTap),
            const SizedBox(width: 8),
            _CircleButton(icon: Icons.copy_rounded, onTap: onCopy),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(color: NB.surface, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: NB.text2),
      ),
    );
  }
}
