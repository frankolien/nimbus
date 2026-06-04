import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/discovery_service.dart';
import '../../domain/trending_token.dart';

final discoveryServiceProvider = Provider((ref) => DiscoveryService());

/// Realtime trending tokens for a given chain id ('all' or a `Network.id`).
/// Fetches immediately, then polls every 60s; a failed refresh keeps the last
/// good data rather than blanking the list. Pull-to-refresh calls [refresh].
final trendingProvider = StateNotifierProvider.autoDispose
    .family<TrendingNotifier, AsyncValue<List<TrendingToken>>, String>(
  (ref, chainId) {
    final notifier =
        TrendingNotifier(ref.watch(discoveryServiceProvider), chainId);
    ref.onDispose(notifier.stop);
    notifier.start();
    return notifier;
  },
);

class TrendingNotifier extends StateNotifier<AsyncValue<List<TrendingToken>>> {
  TrendingNotifier(this._service, this._chainId)
      : super(const AsyncValue.loading());

  final DiscoveryService _service;
  final String _chainId;

  static const _interval = Duration(seconds: 60);
  Timer? _timer;

  void start() {
    _load();
    _timer = Timer.periodic(_interval, (_) => _load());
  }

  void stop() => _timer?.cancel();

  Future<void> refresh() => _load();

  Future<void> _load() async {
    try {
      final tokens = await _service.fetchTrending(_chainId);
      if (mounted) state = AsyncValue.data(tokens);
    } catch (e, st) {
      // Only surface an error if we have nothing to show; otherwise keep the
      // last good list and just log the transient refresh failure.
      if (!mounted) return;
      if (state.hasValue) {
        debugPrint('trending refresh failed ($_chainId): $e');
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
