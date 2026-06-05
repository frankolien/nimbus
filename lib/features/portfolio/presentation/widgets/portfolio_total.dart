import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';

/// The "Total balance" header: a large figure with the cents rendered smaller
/// and dimmed, plus a 24h change pill when real data is available.
class PortfolioTotalHeader extends StatelessWidget {
  const PortfolioTotalHeader(
      {super.key, required this.totalUsd, this.change, this.hidden = false});

  /// Null while the first load is in flight.
  final double? totalUsd;

  /// Real 24h change of the whole portfolio (USD + percent), or null when no
  /// priced asset has a 24h figure yet. When null, no pill is shown.
  final ({double usd, double pct})? change;

  /// When true the figure is masked and the change pill is hidden.
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total balance', style: NB.font(13.5, color: NB.text2)),
        const SizedBox(height: 6),
        _Balance(totalUsd: totalUsd, hidden: hidden),
        if (!hidden && change != null) ...[
          const SizedBox(height: 7),
          _ChangePill(usd: change!.usd, pct: change!.pct),
        ],
      ],
    );
  }
}

/// The big number. Weight stays w500 throughout; only the cents differ — a
/// smaller size and a dimmed colour — for the Phantom-style emphasis on dollars.
class _Balance extends StatelessWidget {
  const _Balance({required this.totalUsd, required this.hidden});
  final double? totalUsd;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final big = NB.font(40, weight: FontWeight.w500, letterSpacing: -1);
    if (hidden) return Text('\$••••••', style: big);
    if (totalUsd == null) return Text('\$—', style: big);

    final formatted = Fmt.usd(totalUsd!); // e.g. $12,480.22
    final dot = formatted.lastIndexOf('.');
    final dollars = dot == -1 ? formatted : formatted.substring(0, dot);
    final cents = dot == -1 ? '' : formatted.substring(dot); // ".22"

    return RichText(
      text: TextSpan(
        style: big,
        children: [
          TextSpan(text: dollars),
          if (cents.isNotEmpty)
            TextSpan(
              text: cents,
              style: NB.font(24, weight: FontWeight.w500, color: NB.text3),
            ),
        ],
      ),
    );
  }
}

/// A green/red pill: `↑ +$312.40 · +2.56%`. Up when the portfolio gained over
/// the last 24h, down otherwise.
class _ChangePill extends StatelessWidget {
  const _ChangePill({required this.usd, required this.pct});
  final double usd;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final up = usd >= 0;
    final color = up ? NB.green : NB.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12,),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? Icons.arrow_upward : Icons.arrow_downward,
              size: 10, color: color),
          const SizedBox(width: 5),
          Text(
            '${up ? '+' : '-'}${Fmt.usd(usd.abs())} · ${Fmt.percent(pct)}',
            style: NB.font(10.5, weight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
