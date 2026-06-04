import '../../wallet/domain/entities/network.dart';

/// Maps a [Network]'s native asset to the ids used by our market-data sources:
/// CoinGecko (for prices + stats) and Binance (for OHLCV candles).
abstract final class MarketIds {
  /// CoinGecko coin id for the network's native asset.
  static const coinGecko = <String, String>{
    'ethereum': 'ethereum',
    'base': 'ethereum',
    'polygon': 'matic-network',
    'solana': 'solana',
    'bitcoin': 'bitcoin',
    'sui': 'sui',
  };

  /// Binance spot symbol for the network's native asset (USDT pair).
  static const binance = <String, String>{
    'ethereum': 'ETHUSDT',
    'base': 'ETHUSDT',
    'polygon': 'POLUSDT',
    'solana': 'SOLUSDT',
    'bitcoin': 'BTCUSDT',
    'sui': 'SUIUSDT',
  };

  static String? coinGeckoId(Network n) => coinGecko[n.id];
  static String? binanceSymbol(Network n) => binance[n.id];
}
