import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xend/xend.dart';

import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../../domain/activity_item.dart';

/// Transfers sent from the Xend wallet, newest first, paged with
/// [ActivityNotifier.loadMore]. Reloads when the SOL balance changes, so a send
/// shows up without a manual refresh.
final activityProvider =
    AsyncNotifierProvider.autoDispose<ActivityNotifier, List<ActivityItem>>(
        ActivityNotifier.new);

class ActivityNotifier extends AutoDisposeAsyncNotifier<List<ActivityItem>> {
  static const pageSize = 20;

  bool _hasMore = true;
  bool _loadingMore = false;
  DateTime? _oldest;

  /// Whether older records may exist past what's loaded.
  bool get hasMore => _hasMore;

  @override
  Future<List<ActivityItem>> build() async {
    final wallet = ref.watch(xendWalletProvider);
    ref.listen<double?>(
      portfolioProvider.select((p) => p.valueOrNull?.entries
          .where((e) => e.network == Network.solana)
          .firstOrNull
          ?.amount),
      (prev, next) {
        if (prev != null && next != null && prev != next) ref.invalidateSelf();
      },
    );
    _hasMore = true;
    _oldest = null;
    if (wallet == null) {
      _hasMore = false;
      return const [];
    }
    return _page(wallet);
  }

  /// Fetch the next older page and append it.
  Future<void> loadMore() async {
    final wallet = ref.read(xendWalletProvider);
    final current = state.valueOrNull;
    if (wallet == null || current == null || !_hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final older = await _page(wallet, before: _oldest);
      state = AsyncData([...current, ...older]);
    } catch (_) {
      // Keep what's shown; the next scroll retries.
    } finally {
      _loadingMore = false;
    }
  }

  Future<List<ActivityItem>> _page(XendWallet wallet, {DateTime? before}) async {
    final records = await wallet.history(
      limit: pageSize,
      before: before?.toUtc().toIso8601String(),
    );
    _hasMore = records.length == pageSize;
    if (records.isNotEmpty) _oldest = records.last.createdAt;
    return [for (final r in records) toActivityItem(r)];
  }
}

/// Tokens we know how to label. History only carries the mint, not decimals.
const _knownMints = <String, ({String symbol, int decimals})>{
  // Circle USDC on devnet.
  '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU': (symbol: 'USDC', decimals: 6),
  // Circle USDC on mainnet.
  'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v': (symbol: 'USDC', decimals: 6),
};

/// Map a Xend history record onto the activity row. The backend only records
/// the wallet's own sends, so every record is outgoing.
ActivityItem toActivityItem(TxRecord r) {
  final mint = r.asset.mint;
  final known = mint == null ? null : _knownMints[mint];
  final symbol = mint == null
      ? Network.solana.nativeSymbol
      : known?.symbol ?? '${mint.substring(0, 4)}…';
  final decimals =
      mint == null ? Network.solana.nativeDecimals : known?.decimals ?? 0;
  return ActivityItem(
    kind: ActivityKind.sent,
    counterparty: r.to,
    amount: r.amount / BigInt.from(10).pow(decimals),
    symbol: symbol,
    signature: r.signature,
    timestamp: r.createdAt.toLocal(),
    failed: r.status == 'failed',
  );
}
