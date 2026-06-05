import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../wallet/domain/entities/network.dart';
import '../../wallet/domain/entities/network_cluster.dart';
import 'rpc_endpoints.dart';

/// Pushes the active Solana account's native balance in realtime over the RPC
/// `accountSubscribe` WebSocket — so incoming SOL shows up the instant it
/// confirms, instead of waiting for the next balance poll.
///
/// `accountSubscribe` only fires on *change* (not an initial value), so the REST
/// poll still seeds the starting balance; this stream layers live updates on
/// top. It reconnects with exponential backoff and, if the socket is
/// unreachable, simply stays quiet — the poll keeps balances correct.
class SolanaAccountStream {
  const SolanaAccountStream({RpcEndpoints endpoints = const RpcEndpoints()})
      : _endpoints = endpoints;

  final RpcEndpoints _endpoints;

  static const _lamportsPerSol = 1000000000; // 1e9
  static const _backoffSeconds = [2, 5, 10, 20, 30];

  /// The WebSocket endpoint for an HTTPS RPC URL — Solana RPC nodes serve the
  /// JSON-RPC WS on the same host under the `wss`/`ws` scheme.
  static String wsUrl(String rpcUrl) {
    if (rpcUrl.startsWith('https://')) {
      return rpcUrl.replaceFirst('https://', 'wss://');
    }
    if (rpcUrl.startsWith('http://')) return rpcUrl.replaceFirst('http://', 'ws://');
    return rpcUrl;
  }

  /// Parse one frame into a balance + its confirmation slot, or null if it
  /// isn't an account notification (e.g. the subscription ack). The slot lets
  /// callers keep balances monotonic. Pure → unit-testable, never throws.
  static ({double sol, int slot})? parseBalance(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['method'] != 'accountNotification') return null;
      final result = (json['params'] as Map?)?['result'] as Map?;
      final lamports = (result?['value'] as Map?)?['lamports'];
      final slot = (result?['context'] as Map?)?['slot'];
      if (lamports is! num || slot is! num) return null;
      return (sol: lamports / _lamportsPerSol, slot: slot.toInt());
    } catch (_) {
      return null;
    }
  }

  /// Stream of [address]'s SOL balance + slot, one event per on-chain change.
  Stream<({double sol, int slot})> watch({
    required String address,
    required NetworkCluster cluster,
  }) {
    final url = wsUrl(_endpoints.urlFor(Network.solana, cluster));

    late StreamController<({double sol, int slot})> controller;
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

    Future<void> connect() async {
      if (disposed) return;
      final WebSocketChannel ch;
      try {
        ch = WebSocketChannel.connect(Uri.parse(url));
        await ch.ready;
      } catch (e) {
        if (!disposed) debugPrint('Solana WS unavailable, using poll: $e');
        scheduleReconnect(connect);
        return;
      }
      if (disposed) {
        ch.sink.close();
        return;
      }
      channel = ch;
      // Subscribe to the account's lamports/data changes at confirmed
      // commitment — fast enough to feel realtime, safe enough to trust.
      ch.sink.add(jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'accountSubscribe',
        'params': [
          address,
          {'encoding': 'base64', 'commitment': 'confirmed'},
        ],
      }));
      sub = ch.stream.listen(
        (msg) {
          attempt = 0; // healthy connection resets backoff
          final update = parseBalance(msg as String);
          if (update != null && !controller.isClosed) controller.add(update);
        },
        onError: (Object e) {
          debugPrint('Solana WS dropped, reconnecting: $e');
          scheduleReconnect(connect);
        },
        onDone: () => scheduleReconnect(connect),
        cancelOnError: true,
      );
    }

    controller = StreamController<({double sol, int slot})>(
      onListen: connect,
      onCancel: () {
        disposed = true;
        cleanup();
      },
    );
    return controller.stream;
  }
}
