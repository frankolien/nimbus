import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';

/// The "Total asset balance" header with a live-status dot.
class PortfolioTotalHeader extends StatelessWidget {
  const PortfolioTotalHeader({super.key, required this.totalUsd, required this.live});

  /// Null while the first load is in flight.
  final double? totalUsd;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Total asset balance', style: NB.font(13.5, color: NB.text2)),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: live ? NB.green : NB.text3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          totalUsd == null ? '\$—' : Fmt.usd(totalUsd!),
          style: NB.font(38, weight: FontWeight.w500, letterSpacing: -1),
        ),
      ],
    );
  }
}
