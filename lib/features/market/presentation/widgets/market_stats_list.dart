import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/market_service.dart';

/// The "Market Stats" section. Renders "—" for figures our data sources don't
/// provide (e.g. holders, liquidity) rather than inventing numbers.
class MarketStatsList extends StatelessWidget {
  const MarketStatsList({super.key, required this.stats, required this.loading});

  final MarketStats? stats;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    final rows = <(IconData, String, String?)>[
      (Icons.pie_chart_outline, 'Market Cap', s == null ? null : Fmt.compactUsd(s.marketCap)),
      (Icons.bar_chart, '24h Volume', s == null ? null : Fmt.compactUsd(s.volume24h)),
      (Icons.grid_view, 'Circ. Supply', s == null ? null : Fmt.compact(s.circulatingSupply)),
      (Icons.trending_up, 'FDV', s == null ? null : Fmt.compactUsd(s.fdv)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.insights, size: 18, color: NB.text2),
          const SizedBox(width: 8),
          Text('Market Stats', style: NB.font(17, weight: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        for (final r in rows) _StatRow(icon: r.$1, label: r.$2, value: r.$3, loading: loading),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.loading,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: NB.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NB.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: NB.text3),
          const SizedBox(width: 10),
          Text(label, style: NB.font(14.5, color: NB.text2)),
          const Spacer(),
          Text(value ?? (loading ? '…' : '—'),
              style: NB.font(15, weight: FontWeight.w800)),
        ],
      ),
    );
  }
}
