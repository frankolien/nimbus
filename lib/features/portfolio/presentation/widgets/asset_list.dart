import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../wallet/domain/entities/network.dart';
import '../providers/portfolio_provider.dart';

/// The "My assets" list. Shows skeleton rows until the first load, then one tile
/// per asset sorted by USD value (highest first).
class AssetList extends StatelessWidget {
  const AssetList({super.key, required this.entries, required this.onTap});

  /// Null while the first portfolio load is in flight (no cache yet).
  final List<PortfolioEntry>? entries;
  final void Function(Network) onTap;

  @override
  Widget build(BuildContext context) {
    final items = entries;
    if (items == null) return const AssetListSkeleton();
    final sorted = [...items]
      ..sort((a, b) => (b.usdValue ?? 0).compareTo(a.usdValue ?? 0));
    return Column(
      children: [
        for (final e in sorted)
          AssetTile(entry: e, onTap: () => onTap(e.network)),
      ],
    );
  }
}

/// One asset row: logo, name + price/change, value + amount.
class AssetTile extends StatelessWidget {
  const AssetTile({super.key, required this.entry, required this.onTap});
  final PortfolioEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            CoinLogo(network: entry.network),
            const SizedBox(width: 13),
            Expanded(child: _nameAndPrice()),
            _valueAndAmount(),
          ],
        ),
      ),
    );
  }

  Widget _nameAndPrice() {
    final price = entry.usdPrice;
    final change = entry.change24h;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(entry.network.displayName, style: NB.font(15.5, weight: FontWeight.w700)),
        const SizedBox(height: 3),
        Row(
          children: [
            Text(price == null ? '—' : Fmt.price(price),
                style: NB.font(12.5, color: NB.text2)),
            if (change != null) ...[
              const SizedBox(width: 8),
              Text(Fmt.percent(change),
                  style: NB.font(12.5,
                      weight: FontWeight.w600,
                      color: change >= 0 ? NB.green : NB.red)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _valueAndAmount() {
    if (entry.error != null) {
      return Text('—', style: NB.font(14, color: NB.text3));
    }
    if (entry.amount == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Skeleton(width: 56, height: 14),
          SizedBox(height: 6),
          Skeleton(width: 38, height: 11),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(entry.usdValue == null ? '—' : Fmt.usd(entry.usdValue!),
            style: NB.font(15, weight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(Fmt.tokenAmount(entry.amount!), style: NB.font(12.5, color: NB.text3)),
      ],
    );
  }
}

/// Skeleton placeholder for the asset list before the first load.
class AssetListSkeleton extends StatelessWidget {
  const AssetListSkeleton({super.key, this.rows = 5});
  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (var i = 0; i < rows; i++) const _AssetTileSkeleton()],
    );
  }
}

class _AssetTileSkeleton extends StatelessWidget {
  const _AssetTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Skeleton.circle(42),
          SizedBox(width: 13),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 90, height: 15),
              SizedBox(height: 7),
              Skeleton(width: 60, height: 12),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Skeleton(width: 56, height: 15),
              SizedBox(height: 7),
              Skeleton(width: 38, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
