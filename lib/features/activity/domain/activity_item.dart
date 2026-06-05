/// Whether a history entry moved value out of (sent) or into (received) the
/// account.
enum ActivityKind { sent, received }

/// One native-SOL movement in the account's history, parsed from a confirmed
/// transaction. Token-only, fee-only, and failed transactions are filtered out
/// upstream, so every item represents a real SOL transfer.
class ActivityItem {
  const ActivityItem({
    required this.kind,
    required this.counterparty,
    required this.amountSol,
    required this.signature,
    required this.timestamp,
  });

  final ActivityKind kind;

  /// The other party's address ('' if it couldn't be resolved).
  final String counterparty;
  final double amountSol;
  final String signature;
  final DateTime? timestamp;

  bool get isReceived => kind == ActivityKind.received;
}
