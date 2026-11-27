/// Whether a history entry moved value out of (sent) or into (received) the
/// account.
enum ActivityKind { sent, received }

/// One transfer in the account's history.
class ActivityItem {
  const ActivityItem({
    required this.kind,
    required this.counterparty,
    required this.amount,
    required this.symbol,
    required this.signature,
    required this.timestamp,
    this.failed = false,
  });

  final ActivityKind kind;

  /// The other party's address ('' if unknown).
  final String counterparty;

  /// Amount in whole units of [symbol].
  final double amount;
  final String symbol;
  final String signature;
  final DateTime? timestamp;

  /// True when the transaction didn't land on chain.
  final bool failed;

  bool get isReceived => kind == ActivityKind.received;
}
