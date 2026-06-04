import '../../../core/network/resilient_http.dart';
import '../domain/trending_token.dart';

/// Fetches the realtime "Trending" token list from CoinGecko's markets endpoint
/// (price, 24h change, 7-day sparkline, logo). The chain chips map to CoinGecko
/// ecosystem categories so the list narrows to the selected chain.
class DiscoveryService {
  DiscoveryService({ResilientHttp? http}) : _http = http ?? ResilientHttp();

  final ResilientHttp _http;

  /// 'all' → no filter; any other chain id → its CoinGecko ecosystem category
  /// (e.g. 'solana' → 'solana-ecosystem'). Unknown categories simply return an
  /// empty list from CoinGecko, which the UI shows as an empty state.
  static String? categoryFor(String chainId) =>
      chainId == 'all' ? null : '$chainId-ecosystem';

  Future<List<TrendingToken>> fetchTrending(String chainId) async {
    final category = categoryFor(chainId);
    final url = Uri.https('api.coingecko.com', '/api/v3/coins/markets', {
      'vs_currency': 'usd',
      'order': 'market_cap_desc',
      'per_page': '20',
      'page': '1',
      'sparkline': 'true',
      'price_change_percentage': '24h',
      if (category != null) 'category': category,
    });
    final list = await _http.getJson(url) as List;
    return [
      for (final m in list) TrendingToken.fromCoinGecko(m as Map<String, dynamic>),
    ];
  }
}
