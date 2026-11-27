import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xend/xend.dart';

import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/domain/entities/network_cluster.dart';
import '../../../wallet/domain/entities/wallet_account.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
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

/// The portfolio for one account at a moment in time.
class Portfolio {
  const Portfolio({required this.entries, this.updatedAt});
  final List<PortfolioEntry> entries;
  final DateTime? updatedAt;

  double get totalUsd =>
      entries.fold(0, (sum, e) => sum + (e.usdValue ?? 0));

  /// The portfolio's 24h change (absolute USD + percent), derived from each
  /// asset's own 24h move weighted by how much of it we hold. Null until at
  /// least one held asset has both a value and a 24h figure — so we render a
  /// pill only when it reflects real data, never a fabricated zero.
  ({double usd, double pct})? get delta24h {
    var prior = 0.0, current = 0.0;
    var any = false;
    for (final e in entries) {
      final value = e.usdValue;
      final change = e.change24h;
      if (value == null || change == null || change <= -100) continue;
      any = true;
      current += value;
      prior += value / (1 + change / 100);
    }
    if (!any || prior == 0) return null;
    return (usd: current - prior, pct: (current - prior) / prior * 100);
  }

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

final priceServiceProvider = Provider((ref) => PriceService());
final binancePriceStreamProvider = Provider((ref) => BinancePriceStream());
final portfolioCacheProvider = Provider((ref) => PortfolioCache());

/// Networks the wallet actually holds. Xend is Solana only, so other chains are
/// left out rather than shown with a zero balance.
const walletNetworks = [Network.solana];

/// Live native-asset prices via the Binance WebSocket.
final livePricesProvider =
    StreamProvider.autoDispose<Map<Network, PriceInfo>>((ref) {
  return ref.watch(binancePriceStreamProvider).watch(walletNetworks);
});

/// Portfolio for the active account. Balances come from the Xend wallet and are
/// polled; prices come from Binance (CoinGecko until the socket is up).
final portfolioProvider = StateNotifierProvider.autoDispose<PortfolioNotifier,
    AsyncValue<Portfolio>>((ref) {
  final account = ref.watch(walletSessionProvider.select((s) => s.activeAccount));
  final notifier = PortfolioNotifier(
    wallet: ref.watch(xendWalletProvider),
    prices: ref.watch(priceServiceProvider),
    cache: ref.watch(portfolioCacheProvider),
    account: account,
    cluster: ref.watch(networkClusterProvider),
  );
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
    required XendWallet? wallet,
    required PriceService prices,
    required PortfolioCache cache,
    required this.account,
    required this.cluster,
  })  : _wallet = wallet,
        _priceService = prices,
        _cache = cache,
        super(const AsyncValue.loading());

  final XendWallet? _wallet;
  final PriceService _priceService;
  final PortfolioCache _cache;
  final WalletAccount? account;
  final NetworkCluster cluster;

  static const _interval = Duration(seconds: 15);
  Timer? _timer;

  /// Latest known price per network (from WS once live, else CoinGecko).
  final Map<Network, PriceInfo> _prices = {};

  /// Set once the WebSocket delivers prices, so CoinGecko stops being polled.
  bool _liveActive = false;

  void start() {
    if (account == null || _wallet == null) {
      state = const AsyncValue.data(Portfolio(entries: []));
      return;
    }
    _bootstrap();
    _timer = Timer.periodic(_interval, (_) => _load());
  }

  /// Show the cached snapshot right away, then refresh.
  Future<void> _bootstrap() async {
    final cached = await _cache.load(account!.index, cluster.id);
    if (cached != null && mounted) {
      try {
        final portfolio = Portfolio.fromJson(cached);
        final entries = [
          for (final e in portfolio.entries)
            if (walletNetworks.contains(e.network)) e,
        ];
        for (final e in entries) {
          if (e.usdPrice != null) {
            _prices[e.network] = PriceInfo(usd: e.usdPrice!, change24h: e.change24h);
          }
        }
        state = AsyncValue.data(
            Portfolio(entries: entries, updatedAt: portfolio.updatedAt));
      } catch (_) {
        // Bad cache, load fresh.
      }
    }
    await _load();
  }

  void stop() => _timer?.cancel();

  /// Re-fetch balances now (pull-to-refresh, after a send).
  Future<void> refresh() => _load();

  /// Apply a live price tick without re-fetching balances.
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
    final wallet = _wallet;
    if (acct == null || wallet == null) return;

    // Balance first. A slow or unreachable price API must never hold it back.
    final entry = await _solanaEntry(wallet);
    if (!mounted) return;
    _publish(acct, entry);

    if (!_liveActive) {
      try {
        _prices.addAll(await _priceService
            .fetchPrices(walletNetworks)
            .timeout(const Duration(seconds: 8)));
      } catch (e) {
        debugPrint('prices failed: $e');
        return;
      }
      if (!mounted) return;
      _publish(acct, entry);
    }
  }

  void _publish(WalletAccount acct, PortfolioEntry entry) {
    // On a failed read keep the last good amount instead of blanking the row.
    final previous = state.valueOrNull?.entries
        .where((e) => e.network == Network.solana)
        .firstOrNull;
    final shown = entry.error != null && previous?.amount != null
        ? previous!
        : entry;
    final portfolio = Portfolio(
      entries: [_priced(shown)],
      updatedAt: DateTime.now(),
    );
    state = AsyncValue.data(portfolio);
    if (entry.error == null) {
      unawaited(_cache.save(acct.index, cluster.id, portfolio.toJson()));
    }
  }

  Future<PortfolioEntry> _solanaEntry(XendWallet wallet) async {
    const network = Network.solana;
    try {
      final b = await wallet.balance();
      return PortfolioEntry(
        network: network,
        address: wallet.address,
        amount: _toUnits(b.amount, network.nativeDecimals),
      );
    } catch (e) {
      debugPrint('balance solana failed: $e');
      return PortfolioEntry(
          network: network, address: wallet.address, error: 'unavailable');
    }
  }

  static double _toUnits(BigInt raw, int decimals) =>
      raw / BigInt.from(10).pow(decimals);

  /// Attach the cached price/change to a balance entry.
  PortfolioEntry _priced(PortfolioEntry e) {
    final p = _prices[e.network];
    if (p == null) return e;
    return e.copyWith(usdPrice: p.usd, change24h: p.change24h, error: e.error);
  }
}
