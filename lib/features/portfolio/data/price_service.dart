import '../../../core/network/resilient_http.dart';
import '../../market/data/market_ids.dart';
import '../../wallet/domain/entities/network.dart';

/// Fetches USD spot prices for the native assets from CoinGecko.
class PriceService {
  PriceService({ResilientHttp? http}) : _http = http ?? ResilientHttp();

  final ResilientHttp _http;

  /// USD spot price and 24h % change per network. Networks whose price
  /// couldn't be fetched are omitted (callers treat missing as "unknown").
  Future<Map<Network, PriceInfo>> fetchPrices(List<Network> networks) async {
    final ids = networks.map((n) => MarketIds.coinGecko[n.id]).whereType<String>().toSet();
    if (ids.isEmpty) return {};
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price'
      '?ids=${ids.join(',')}&vs_currencies=usd&include_24hr_change=true',
    );
    final json = await _http.getJson(url) as Map<String, dynamic>;
    final result = <Network, PriceInfo>{};
    for (final n in networks) {
      final id = MarketIds.coinGecko[n.id];
      final entry = id == null ? null : json[id];
      final usd = entry?['usd'];
      if (usd is num) {
        final change = entry['usd_24h_change'];
        result[n] = PriceInfo(
          usd: usd.toDouble(),
          change24h: change is num ? change.toDouble() : null,
        );
      }
    }
    return result;
  }
}

/// A spot price plus its 24-hour percentage change.
class PriceInfo {
  const PriceInfo({required this.usd, this.change24h});
  final double usd;
  final double? change24h;
}
