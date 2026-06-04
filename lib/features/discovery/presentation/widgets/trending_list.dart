import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../domain/trending_token.dart';
import 'sparkline.dart';

/// The "Trending" card: live token rows (logo, symbol/name, sparkline, price,
/// 24h change) separated by hairline dividers.
class TrendingList extends StatelessWidget {
  const TrendingList({super.key, required this.tokens, required this.onTap});

  final List<TrendingToken> tokens;
  final ValueChanged<TrendingToken> onTap;

  @override
  Widget build(BuildContext context) {
    return _card([
      for (var i = 0; i < tokens.length; i++) ...[
        TrendingTile(token: tokens[i], onTap: () => onTap(tokens[i])),
        if (i < tokens.length - 1)
          const Divider(height: 1, thickness: 1, color: NB.border),
      ],
    ]);
  }

  static Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: NB.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NB.border),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(children: children),
      );
}

class TrendingTile extends StatelessWidget {
  const TrendingTile({super.key, required this.token, required this.onTap});

  final TrendingToken token;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final up = token.isUp;
    final changeColor = up ? NB.green : NB.red;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _TokenLogo(url: token.imageUrl, symbol: token.symbol),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(token.symbol,
                      style: NB.font(14.5, weight: FontWeight.w700)),
                  const SizedBox(height: 1),
                  Text(token.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NB.font(12, color: NB.text2)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (token.sparkline.length > 1)
              Sparkline(values: token.sparkline, color: changeColor),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Fmt.marketPrice(token.price),
                    style: NB.font(14, weight: FontWeight.w700)),
                const SizedBox(height: 1),
                Text(token.change24h == null ? '—' : Fmt.percent(token.change24h!),
                    style: NB.font(12,
                        weight: FontWeight.w700, color: changeColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Token logo from CoinGecko with a monogram fallback while loading / on error.
class _TokenLogo extends StatelessWidget {
  const _TokenLogo({required this.url, required this.symbol});
  final String url;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    const size = 36.0;
    final fallback = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: NB.surface3, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(symbol.isEmpty ? '?' : symbol.substring(0, 1),
          style: NB.font(13, weight: FontWeight.w800, color: NB.text2)),
    );
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 3).round(),
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

/// Shimmer placeholder shown before the first trending load.
class TrendingListSkeleton extends StatelessWidget {
  const TrendingListSkeleton({super.key, this.rows = 6});
  final int rows;

  @override
  Widget build(BuildContext context) {
    return TrendingList._card([
      for (var i = 0; i < rows; i++) ...[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Skeleton.circle(36),
              SizedBox(width: 11),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 48, height: 13),
                  SizedBox(height: 6),
                  Skeleton(width: 70, height: 11),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Skeleton(width: 54, height: 13),
                  SizedBox(height: 6),
                  Skeleton(width: 36, height: 11),
                ],
              ),
            ],
          ),
        ),
        if (i < rows - 1)
          const Divider(height: 1, thickness: 1, color: NB.border),
      ],
    ]);
  }
}
