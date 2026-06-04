import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/domain/entities/network_cluster.dart';
import '../../../wallet/domain/entities/wallet_account.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../../data/balance_service.dart';
import '../../data/binance_price_stream.dart';
import '../../data/portfolio_cache.dart';
import '../../data/price_service.dart';
import 'network_cluster_provider.dart';

/// One network's slice of the portfolio.
class PortfolioEntry {
  const PortfolioEntry({
    required this.network,
    required this.address,
    this.amount,
    this.usdPrice,
    this.change24h,
    this.error,
  });

  final Network network;
  final String address;
  final double? amount;
  final double? usdPrice;
  final double? change24h;
  final String? error;

  double? get usdValue =>
      (amount != null && usdPrice != null) ? amount! * usdPrice! : null;

  PortfolioEntry copyWith({
    double? amount,
    double? usdPrice,
    double? change24h,
    String? error,
  }) =>
      PortfolioEntry(
        network: network,
        address: address,
        amount: amount ?? this.amount,
        usdPrice: usdPrice ?? this.usdPrice,
        change24h: change24h ?? this.change24h,
        error: error,
      );

  // `error` is intentionally not cached — a cached entry represents good data.
  Map<String, dynamic> toJson() => {
        'network': network.id,
        'address': address,
        if (amount != null) 'amount': amount,
        if (usdPrice != null) 'usdPrice': usdPrice,
        if (change24h != null) 'change24h': change24h,
      };

  factory PortfolioEntry.fromJson(Map<String, dynamic> j) => PortfolioEntry(
        network: Network.fromId(j['network'] as String),
        address: j['address'] as String,
        amount: (j['amount'] as num?)?.toDouble(),
        usdPrice: (j['usdPrice'] as num?)?.toDouble(),
        change24h: (j['change24h'] as num?)?.toDouble(),
      );
}

/// The whole multi-chain portfolio for one account at a moment in time.
class Portfolio {
  const Portfolio({required this.entries, this.updatedAt});
  final List<PortfolioEntry> entries;
  final DateTime? updatedAt;

  double get totalUsd =>
      entries.fold(0, (sum, e) => sum + (e.usdValue ?? 0));

  Map<String, dynamic> toJson() => {
        'entries': entries.map((e) => e.toJson()).toList(),
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
      };

  factory Portfolio.fromJson(Map<String, dynamic> j) => Portfolio(
        entries: [
          for (final e in (j['entries'] as List))
            PortfolioEntry.fromJson(e as Map<String, dynamic>),
        ],
        updatedAt: j['updatedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(j['updatedAt'] as int),
      );
}

final balanceServiceProvider = Provider((ref) => BalanceService());
final priceServiceProvider = Provider((ref) => PriceService());
final binancePriceStreamProvider = Provider((ref) => BinancePriceStream());
final portfolioCacheProvider = Provider((ref) => PortfolioCache());

/// Live native-asset prices via the Binance WebSocket (sub-second updates).
final livePricesProvider =
    StreamProvider.autoDispose<Map<Network, PriceInfo>>((ref) {
  return ref.watch(binancePriceStreamProvider).watch(Network.values);
});

/// Realtime portfolio for the active account. Balances are polled; prices come
/// live from the Binance WebSocket (with a CoinGecko REST bootstrap/fallback so
/// values appear instantly and survive a blocked socket). Rebuilds when the
/// active account changes.
final portfolioProvider = StateNotifierProvider.autoDispose<PortfolioNotifier,
    AsyncValue<Portfolio>>((ref) {
  final account = ref.watch(walletSessionProvider.select((s) => s.activeAccount));
  final cluster = ref.watch(networkClusterProvider);
  final notifier = PortfolioNotifier(
    balances: ref.watch(balanceServiceProvider),
    prices: ref.watch(priceServiceProvider),
    cache: ref.watch(portfolioCacheProvider),
    account: account,
    cluster: cluster,
  );
  // Forward live WebSocket prices into the notifier as they arrive.
  ref.listen<AsyncValue<Map<Network, PriceInfo>>>(
    livePricesProvider,
    (_, next) => notifier.applyLivePrices(next.valueOrNull),
  );
  ref.onDispose(notifier.stop);
  notifier.start();
  return notifier;
});

class PortfolioNotifier extends StateNotifier<AsyncValue<Portfolio>> {
  PortfolioNotifier({
    required BalanceService balances,
    required PriceService prices,
    required PortfolioCache cache,
    required this.account,
    required this.cluster,
  })  : _balances = balances,
        _priceService = prices,
        _cache = cache,
        super(const AsyncValue.loading());

  final BalanceService _balances;
  final PriceService _priceService;
  final PortfolioCache _cache;
  final WalletAccount? account;
  final NetworkCluster cluster;

  static const _interval = Duration(seconds: 20);
  static const _networks = Network.values;
  Timer? _timer;

  /// Latest known price per network (from WS once live, else CoinGecko).
  final Map<Network, PriceInfo> _prices = {};

  /// True once the WebSocket has delivered prices; we then stop pulling
  /// CoinGecko so the two sources don't fight over the value.
  bool _liveActive = false;

  void start() {
    if (account == null) {
      state = const AsyncValue.data(Portfolio(entries: []));
      return;
    }
    _bootstrap();
    _timer = Timer.periodic(_interval, (_) => _load());
  }

  /// Show the cached snapshot immediately (no skeleton on relaunch), then
  /// refresh in the background.
  Future<void> _bootstrap() async {
    final cached = await _cache.load(account!.index, cluster.id);
    if (cached != null && mounted) {
      try {
        final portfolio = Portfolio.fromJson(cached);
        for (final e in portfolio.entries) {
          if (e.usdPrice != null) {
            _prices[e.network] = PriceInfo(usd: e.usdPrice!, change24h: e.change24h);
          }
        }
        state = AsyncValue.data(portfolio);
      } catch (_) {
        // Corrupt cache — ignore and load fresh.
      }
    }
    await _load();
  }

  void stop() => _timer?.cancel();

  /// Manual refresh (pull-to-refresh) — re-fetches balances.
  Future<void> refresh() => _load();

  /// Apply a live price tick from the Binance WebSocket: update prices in place
  /// without re-fetching balances, so the total moves in realtime.
  void applyLivePrices(Map<Network, PriceInfo>? prices) {
    if (prices == null || prices.isEmpty) return;
    _liveActive = true;
    _prices.addAll(prices);
    final current = state.valueOrNull;
    if (current == null || !mounted) return;
    state = AsyncValue.data(Portfolio(
      entries: [for (final e in current.entries) _priced(e)],
      updatedAt: current.updatedAt,
    ));
  }

  Future<void> _load() async {
    final acct = account;
    if (acct == null) return;

    // Resolve the address for each network from its chain family.
    final targets = <Network, String>{};
    for (final n in _networks) {
      final a = acct.account(n.family);
      if (a != null) targets[n] = a.address;
    }

    // Fetch balances per-network independently so one failing chain doesn't
    // sink the others.
    final balanceFutures = targets.entries.map((e) async {
      try {
        final b = await _balances.fetch(e.key, e.value, cluster);
        return PortfolioEntry(network: e.key, address: e.value, amount: b.amount);
      } catch (err) {
        debugPrint('balance ${e.key.id} failed: $err');
        return PortfolioEntry(network: e.key, address: e.value, error: 'unavailable');
      }
    }).toList();

    // Bootstrap prices from REST until the WebSocket takes over.
    if (!_liveActive) {
      try {
        _prices.addAll(await _priceService.fetchPrices(targets.keys.toList()));
      } catch (e) {
        debugPrint('prices failed: $e');
      }
    }

    final entries = await Future.wait(balanceFutures);
    if (!mounted) return;
    final portfolio = Portfolio(
      entries: [for (final e in entries) _priced(e)],
      updatedAt: DateTime.now(),
    );
    state = AsyncValue.data(portfolio);
    // Persist the snapshot so the next launch shows it instantly.
    unawaited(_cache.save(acct.index, cluster.id, portfolio.toJson()));
  }

  /// Attach the cached price/change to a balance entry.
  PortfolioEntry _priced(PortfolioEntry e) {
    final p = _prices[e.network];
    if (p == null) return e;
    return e.copyWith(usdPrice: p.usd, change24h: p.change24h, error: e.error);
  }
}
