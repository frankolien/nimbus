import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../wallet/domain/entities/network.dart';

/// Token logo + name + symbol with a verified badge.
class TokenIdentity extends StatelessWidget {
  const TokenIdentity({super.key, required this.network});
  final Network network;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CoinLogo(network: network, size: 52),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(network.displayName,
                style: NB.font(24, weight: FontWeight.w800, letterSpacing: -0.4)),
            const SizedBox(height: 2),
            Row(children: [
              Text(network.nativeSymbol, style: NB.font(14, color: NB.text2)),
              const SizedBox(width: 6),
              const Icon(Icons.verified, size: 15, color: NB.orange),
            ]),
          ],
        ),
      ],
    );
  }
}

/// Big price (tinted by direction) with a 24h change row.
class TokenPriceHeader extends StatelessWidget {
  const TokenPriceHeader({super.key, required this.price, required this.change24h});
  final double? price;
  final double? change24h;

  @override
  Widget build(BuildContext context) {
    final change = change24h;
    final up = (change ?? 0) >= 0;
    final color = change == null ? NB.text : (up ? NB.green : NB.red);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          price == null ? '\$—' : Fmt.usd(price!),
          style: NB.font(40, weight: FontWeight.w800, letterSpacing: -1, color: color),
        ),
        if (change != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            Icon(up ? Icons.arrow_upward : Icons.arrow_downward,
                size: 15, color: up ? NB.green : NB.red),
            const SizedBox(width: 2),
            Text('${change.toStringAsFixed(2)}%',
                style: NB.font(14,
                    weight: FontWeight.w700, color: up ? NB.green : NB.red)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: NB.border),
              ),
              child: Text('24H', style: NB.font(12, color: NB.text2)),
            ),
          ]),
        ],
      ],
    );
  }
}
