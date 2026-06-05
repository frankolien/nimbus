import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../wallet/domain/entities/network.dart';

/// The native assets the wallet can currently send. SPL/ERC-20 token balances
/// join this list once token support lands.
const sendableNetworks = [
  Network.ethereum,
  Network.polygon,
  Network.base,
  Network.solana,
];

/// Bottom sheet to pick which asset to send. Returns the chosen [Network], or
/// null if dismissed.
Future<Network?> showSelectTokenSheet(BuildContext context) {
  return showModalBottomSheet<Network>(
    context: context,
    backgroundColor: NB.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _SelectTokenSheet(),
  );
}

class _SelectTokenSheet extends ConsumerStatefulWidget {
  const _SelectTokenSheet();

  @override
  ConsumerState<_SelectTokenSheet> createState() => _SelectTokenSheetState();
}

class _SelectTokenSheetState extends ConsumerState<_SelectTokenSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(portfolioProvider).valueOrNull?.entries ?? [];
    double balanceOf(Network n) {
      for (final e in entries) {
        if (e.network == n) return e.amount ?? 0;
      }
      return 0;
    }

    double? priceOf(Network n) {
      for (final e in entries) {
        if (e.network == n) return e.usdPrice;
      }
      return null;
    }

    final q = _search.text.trim().toLowerCase();
    final tokens = sendableNetworks
        .where((n) =>
            q.isEmpty ||
            n.displayName.toLowerCase().contains(q) ||
            n.nativeSymbol.toLowerCase().contains(q))
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NB.surface3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 10, 6),
              child: Row(
                children: [
                  Text('Select Token',
                      style: NB.font(21, weight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: NB.text2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
              child: SearchField(
                controller: _search,
                hint: 'Search...',
                onChanged: (_) => setState(() {}),
                onClear: () => setState(_search.clear),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                itemCount: tokens.length,
                itemBuilder: (context, i) {
                  final n = tokens[i];
                  return _TokenRow(
                    network: n,
                    balance: balanceOf(n),
                    usdPrice: priceOf(n),
                    onTap: () => Navigator.of(context).pop(n),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  const _TokenRow({
    required this.network,
    required this.balance,
    required this.usdPrice,
    required this.onTap,
  });

  final Network network;
  final double balance;
  final double? usdPrice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final usd = usdPrice == null ? null : balance * usdPrice!;
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
                  Text(network.displayName,
                      style: NB.font(15.5, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('${Fmt.tokenAmount(balance)} ${network.nativeSymbol}',
                      style: NB.font(12.5, color: NB.text2)),
                ],
              ),
            ),
            if (usd != null)
              Text(Fmt.usd(usd),
                  style: NB.font(14, weight: FontWeight.w700, color: NB.text)),
          ],
        ),
      ),
    );
  }
}
