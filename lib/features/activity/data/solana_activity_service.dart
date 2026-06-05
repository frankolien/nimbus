import '../../../core/network/resilient_http.dart';
import '../../portfolio/data/rpc_endpoints.dart';
import '../../wallet/domain/entities/network.dart';
import '../../wallet/domain/entities/network_cluster.dart';
import '../domain/activity_item.dart';

/// Fetches native-SOL transaction history for an address: recent signatures via
/// `getSignaturesForAddress`, then each transaction via `getTransaction`
/// (jsonParsed). The parsing is split into a pure [parseTransaction] so it can
/// be unit-tested without the network.
class SolanaActivityService {
  SolanaActivityService({
    ResilientHttp? http,
    RpcEndpoints endpoints = const RpcEndpoints(),
  })  : _http = http ?? ResilientHttp(),
        _endpoints = endpoints;

  final ResilientHttp _http;
  final RpcEndpoints _endpoints;

  static const _lamportsPerSol = 1000000000;

  Future<List<ActivityItem>> fetch({
    required String address,
    required NetworkCluster cluster,
    int limit = 20,
  }) async {
    final url = Uri.parse(_endpoints.urlFor(Network.solana, cluster));

    final sigsRes = await _http.postJson(url, {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'getSignaturesForAddress',
      'params': [
        address,
        {'limit': limit},
      ],
    });
    final sigs = ((sigsRes as Map<String, dynamic>?)?['result'] as List?) ?? [];

    final futures = sigs.map((s) async {
      final signature = (s as Map<String, dynamic>)['signature'] as String?;
      if (signature == null) return null;
      try {
        final txRes = await _http.postJson(url, {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getTransaction',
          'params': [
            signature,
            {'encoding': 'jsonParsed', 'maxSupportedTransactionVersion': 0},
          ],
        });
        return parseTransaction(txRes as Map<String, dynamic>, address);
      } catch (_) {
        return null;
      }
    }).toList();

    final items = await Future.wait(futures);
    return items.whereType<ActivityItem>().toList()
      ..sort((a, b) => (b.timestamp ?? DateTime(0))
          .compareTo(a.timestamp ?? DateTime(0)));
  }

  /// Parse a `getTransaction` response into an [ActivityItem], or null if the
  /// transaction failed, didn't involve [address], or moved no native SOL
  /// (e.g. a token-only or fee-only transaction). Pure → unit-testable.
  static ActivityItem? parseTransaction(
      Map<String, dynamic> json, String address) {
    final result = json['result'] as Map<String, dynamic>?;
    if (result == null) return null;
    final meta = result['meta'] as Map<String, dynamic>?;
    final message =
        (result['transaction'] as Map<String, dynamic>?)?['message']
            as Map<String, dynamic>?;
    if (meta == null || message == null) return null;
    if (meta['err'] != null) return null; // skip failed transactions

    final keys = _accountKeys(message['accountKeys']);
    final idx = keys.indexOf(address);
    if (idx == -1) return null;

    final sigList =
        (result['transaction'] as Map<String, dynamic>?)?['signatures'] as List?;
    final signature =
        (sigList != null && sigList.isNotEmpty) ? sigList.first as String : '';
    final blockTime = (result['blockTime'] as num?)?.toInt();
    final timestamp = blockTime == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(blockTime * 1000);

    // Prefer the exact amount + counterparty from parsed System transfers.
    final transfer = _findTransfer(message, meta, address);
    int lamports;
    ActivityKind kind;
    String counterparty;
    if (transfer != null) {
      kind = transfer.sent ? ActivityKind.sent : ActivityKind.received;
      lamports = transfer.lamports;
      counterparty = transfer.counterparty;
    } else {
      // Fallback to the account's net balance change.
      final pre = (meta['preBalances'] as List?) ?? const [];
      final post = (meta['postBalances'] as List?) ?? const [];
      if (idx >= pre.length || idx >= post.length) return null;
      final fee = (meta['fee'] as num?)?.toInt() ?? 0;
      final delta =
          (post[idx] as num).toInt() - (pre[idx] as num).toInt();
      if (delta >= 0) {
        kind = ActivityKind.received;
        lamports = delta;
      } else {
        kind = ActivityKind.sent;
        lamports = -delta - (idx == 0 ? fee : 0); // drop the fee for the payer
      }
      counterparty = _largestCounterparty(keys, pre, post, idx);
    }

    if (lamports <= 0) return null; // no net SOL movement

    return ActivityItem(
      kind: kind,
      counterparty: counterparty,
      amountSol: lamports / _lamportsPerSol,
      signature: signature,
      timestamp: timestamp,
    );
  }

  static List<String> _accountKeys(dynamic raw) {
    if (raw is! List) return const [];
    return [
      for (final k in raw)
        if (k is String)
          k
        else if (k is Map && k['pubkey'] is String)
          k['pubkey'] as String,
    ];
  }

  /// Net the System-transfer instructions (outer + inner) involving [address]
  /// into a single direction + amount + counterparty.
  static ({bool sent, int lamports, String counterparty})? _findTransfer(
      Map<String, dynamic> message, Map<String, dynamic> meta, String address) {
    final instrs = <Map<String, dynamic>>[
      for (final i in (message['instructions'] as List? ?? []))
        if (i is Map<String, dynamic>) i,
      for (final group in (meta['innerInstructions'] as List? ?? []))
        for (final i in ((group as Map)['instructions'] as List? ?? []))
          if (i is Map<String, dynamic>) i,
    ];

    var sent = 0, received = 0;
    String? sentTo, receivedFrom;
    for (final ix in instrs) {
      if (ix['program'] != 'system') continue;
      final parsed = ix['parsed'];
      if (parsed is! Map || parsed['type'] != 'transfer') continue;
      final info = parsed['info'] as Map<String, dynamic>?;
      if (info == null) continue;
      final lamports = (info['lamports'] as num?)?.toInt() ?? 0;
      if (info['source'] == address) {
        sent += lamports;
        sentTo ??= info['destination'] as String?;
      } else if (info['destination'] == address) {
        received += lamports;
        receivedFrom ??= info['source'] as String?;
      }
    }

    if (sent == 0 && received == 0) return null;
    final net = received - sent;
    return net >= 0
        ? (sent: false, lamports: net, counterparty: receivedFrom ?? '')
        : (sent: true, lamports: -net, counterparty: sentTo ?? '');
  }

  static String _largestCounterparty(
      List<String> keys, List pre, List post, int userIdx) {
    var bestIdx = -1, bestMag = 0;
    for (var i = 0; i < keys.length; i++) {
      if (i == userIdx || i >= pre.length || i >= post.length) continue;
      final mag = ((post[i] as num).toInt() - (pre[i] as num).toInt()).abs();
      if (mag > bestMag) {
        bestMag = mag;
        bestIdx = i;
      }
    }
    return bestIdx == -1 ? '' : keys[bestIdx];
  }
}
