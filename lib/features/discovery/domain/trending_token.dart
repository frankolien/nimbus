/// A token shown in the Discovery "Trending" list, sourced live from CoinGecko
/// markets (price, 24h change, 7-day sparkline, official logo).
class TrendingToken {
  const TrendingToken({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.change24h,
    required this.sparkline,
  });

  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final double price;
  final double? change24h;

  /// 7-day price points (CoinGecko `sparkline_in_7d`), oldest → newest.
  final List<double> sparkline;

  bool get isUp => (change24h ?? 0) >= 0;

  factory TrendingToken.fromCoinGecko(Map<String, dynamic> j) {
    final spark = (j['sparkline_in_7d']?['price'] as List?) ?? const [];
    return TrendingToken(
      id: j['id'] as String? ?? '',
      symbol: (j['symbol'] as String? ?? '').toUpperCase(),
      name: j['name'] as String? ?? '',
      imageUrl: j['image'] as String? ?? '',
      price: (j['current_price'] as num?)?.toDouble() ?? 0,
      change24h: (j['price_change_percentage_24h'] as num?)?.toDouble(),
      sparkline: [for (final p in spark) (p as num).toDouble()],
    );
  }
}
