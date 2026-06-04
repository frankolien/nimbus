import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../market/data/market_ids.dart';
import '../../wallet/domain/entities/network.dart';
import 'price_service.dart';

/// Live native-asset prices via the Binance combined `@ticker` WebSocket.
///
/// Emits a map of every network's latest price + 24h change on each tick
/// (~1/sec per symbol). The socket reconnects with exponential backoff if it
/// drops (Binance closes connections after 24h and on transient errors), and
/// is fully torn down when the returned stream is cancelled. If Binance is
/// unreachable (e.g. geo-blocked), the stream simply stays quiet — callers fall
/// back to their REST price source.
class BinancePriceStream {
  static const _base = 'wss://stream.binance.com:9443/stream?streams=';
  // Settles to a 60s retry so a geo-blocked Binance doesn't hammer the network
  // (CoinGecko REST covers prices in the meantime).
  static const _backoffSeconds = [2, 5, 10, 30, 60];

  /// Lowercase Binance symbol → networks that use it. ETH backs both Ethereum
  /// and Base, so one symbol can map to multiple networks.
  static Map<String, List<Network>> symbolMap(List<Network> networks) {
    final map = <String, List<Network>>{};
    for (final n in networks) {
      final symbol = MarketIds.binanceSymbol(n)?.toLowerCase();
      if (symbol != null) map.putIfAbsent(symbol, () => []).add(n);
    }
    return map;
  }

  /// Parse one combined-stream frame into price updates. Returns an empty map
  /// for irrelevant or malformed frames (never throws). Pure → unit-testable.
  static Map<Network, PriceInfo> parseFrame(
    String raw,
    Map<String, List<Network>> symbolToNetworks,
  ) {
    final out = <Network, PriceInfo>{};
    try {
      final data = (jsonDecode(raw) as Map<String, dynamic>)['data']
          as Map<String, dynamic>?;
      if (data == null) return out;
      final symbol = (data['s'] as String?)?.toLowerCase();
      final price = double.tryParse(data['c']?.toString() ?? '');
      final change = double.tryParse(data['P']?.toString() ?? '');
      final nets = symbol == null ? null : symbolToNetworks[symbol];
      if (nets == null || price == null) return out;
      for (final n in nets) {
        out[n] = PriceInfo(usd: price, change24h: change);
      }
    } catch (_) {
      // Malformed frame — ignore, keep the stream alive.
    }
    return out;
  }

  Stream<Map<Network, PriceInfo>> watch(List<Network> networks) {
    final symbolToNetworks = symbolMap(networks);
    if (symbolToNetworks.isEmpty) return const Stream.empty();

    final url = _base +
        symbolToNetworks.keys.map((s) => '$s@ticker').join('/');
    final latest = <Network, PriceInfo>{};

    late StreamController<Map<Network, PriceInfo>> controller;
    WebSocketChannel? channel;
    StreamSubscription<dynamic>? sub;
    Timer? retryTimer;
    var attempt = 0;
    var disposed = false;

    void cleanup() {
      retryTimer?.cancel();
      sub?.cancel();
      channel?.sink.close();
      sub = null;
      channel = null;
    }

    void scheduleReconnect(void Function() connect) {
      cleanup();
      if (disposed) return;
      final secs = _backoffSeconds[min(attempt, _backoffSeconds.length - 1)];
      attempt++;
      retryTimer = Timer(Duration(seconds: secs), connect);
    }

    void onTick(dynamic raw) {
      final updates = parseFrame(raw as String, symbolToNetworks);
      if (updates.isEmpty) return;
      latest.addAll(updates);
      if (!controller.isClosed) controller.add(Map.of(latest));
    }

    Future<void> connect() async {
      if (disposed) return;
      final WebSocketChannel ch;
      try {
        ch = WebSocketChannel.connect(Uri.parse(url));
        // Connection failures (DNS, refused, geo-block) surface here — awaiting
        // catches them instead of letting `ready` reject as an unhandled error.
        await ch.ready;
      } catch (e) {
        if (!disposed) debugPrint('Binance WS unavailable, using REST: $e');
        scheduleReconnect(connect);
        return;
      }
      if (disposed) {
        ch.sink.close();
        return;
      }
      channel = ch;
      sub = ch.stream.listen(
        (msg) {
          attempt = 0; // healthy connection resets backoff
          onTick(msg);
        },
        onError: (Object e) {
          debugPrint('Binance WS dropped, reconnecting: $e');
          scheduleReconnect(connect);
        },
        onDone: () => scheduleReconnect(connect),
        cancelOnError: true,
      );
    }

    controller = StreamController<Map<Network, PriceInfo>>(
      onListen: connect,
      onCancel: () {
        disposed = true;
        cleanup();
      },
    );
    return controller.stream;
  }
}
