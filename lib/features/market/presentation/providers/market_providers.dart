import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../wallet/domain/entities/network.dart';
import '../../data/market_service.dart';

final marketServiceProvider = Provider((ref) => MarketService());

/// Candles for a (network, timeframe) pair. Auto-disposes when unwatched.
final candlesProvider = FutureProvider.autoDispose
    .family<List<Candle>, (Network, Timeframe)>((ref, key) {
  return ref.watch(marketServiceProvider).fetchCandles(key.$1, key.$2);
});

/// Market stats for a network's native asset.
final marketStatsProvider =
    FutureProvider.autoDispose.family<MarketStats, Network>((ref, network) {
  return ref.watch(marketServiceProvider).fetchStats(network);
});
