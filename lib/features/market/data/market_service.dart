import '../../../core/network/resilient_http.dart';
import '../../wallet/domain/entities/network.dart';
import 'market_ids.dart';

/// One OHLC(V) candle. Volume is 0 when the source doesn't provide it
/// (CoinGecko OHLC has no volume); the chart hides its volume strip in that case.
class Candle {
  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume = 0,
  });

  final DateTime time;
  final double open, high, low, close;
  final double volume;
  bool get isUp => close >= open;
}

/// Chart ranges, mapped to CoinGecko OHLC `days`. CoinGecko picks candle
/// granularity from the range: 1d → 30-min candles, 7–30d → 4-hour, >30d → daily.
enum Timeframe {
  d1('1D', 1),
  w1('1W', 7),
  m1('1M', 30),
  y1('1Y', 365);

  const Timeframe(this.label, this.days);
  final String label;
  final int days;
}

/// Market statistics for an asset (from CoinGecko). Fields we can't source are
/// left null and rendered as "—" rather than faked.
class MarketStats {
  const MarketStats({
    this.marketCap,
    this.volume24h,
    this.circulatingSupply,
    this.fdv,
  });

  final double? marketCap;
  final double? volume24h;
  final double? circulatingSupply;
  final double? fdv;
}

/// Fetches OHLC candles and market stats for an asset, both from CoinGecko.
class MarketService {
  MarketService({ResilientHttp? http}) : _http = http ?? ResilientHttp();

  final ResilientHttp _http;

  /// OHLC candles from CoinGecko (reachable wherever the rest of the app is;
  /// Binance is geo-blocked in some regions). Format: [time, o, h, l, c].
  Future<List<Candle>> fetchCandles(Network network, Timeframe tf) async {
    final id = MarketIds.coinGeckoId(network);
    if (id == null) return const [];
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/$id/ohlc'
      '?vs_currency=usd&days=${tf.days}',
    );
    final list = await _http.getJson(url) as List;
    return [
      for (final row in list)
        Candle(
          time: DateTime.fromMillisecondsSinceEpoch((row[0] as num).toInt()),
          open: (row[1] as num).toDouble(),
          high: (row[2] as num).toDouble(),
          low: (row[3] as num).toDouble(),
          close: (row[4] as num).toDouble(),
        ),
    ];
  }

  Future<MarketStats> fetchStats(Network network) async {
    final id = MarketIds.coinGeckoId(network);
    if (id == null) return const MarketStats();
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/$id'
      '?localization=false&tickers=false&community_data=false'
      '&developer_data=false&sparkline=false',
    );
    final json = await _http.getJson(url) as Map<String, dynamic>;
    final m = json['market_data'] as Map<String, dynamic>?;
    double? usd(String key) => (m?[key]?['usd'] as num?)?.toDouble();
    return MarketStats(
      marketCap: usd('market_cap'),
      volume24h: usd('total_volume'),
      circulatingSupply: (m?['circulating_supply'] as num?)?.toDouble(),
      fdv: usd('fully_diluted_valuation'),
    );
  }
}
