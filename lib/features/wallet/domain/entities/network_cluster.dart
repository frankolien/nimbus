/// A blockchain *environment* the wallet connects to. Every chain exists on each
/// cluster with completely separate state; only [mainnet] holds assets with
/// real-world value. [testnet] and [devnet] are for development — their coins
/// are free (via faucets) and worthless.
///
/// Selecting a cluster switches the RPC endpoints used for balances and
/// transactions across all chains at once. Chains without a literal "devnet"
/// (EVM, Bitcoin) fall back to their nearest test environment.
enum NetworkCluster {
  mainnet(id: 'mainnet', label: 'Mainnet', blurb: 'Real assets and live value'),
  testnet(
      id: 'testnet',
      label: 'Testnet',
      blurb: 'Public test chains — no real value'),
  devnet(
      id: 'devnet',
      label: 'Devnet',
      blurb: 'Developer chains with free faucets');

  const NetworkCluster({
    required this.id,
    required this.label,
    required this.blurb,
  });

  /// Stable identifier for storage/serialization. Never change.
  final String id;

  /// Human-readable name for the selector and badges.
  final String label;

  /// One-line description shown beside each option.
  final String blurb;

  bool get isMainnet => this == NetworkCluster.mainnet;

  static NetworkCluster fromId(String id) =>
      values.firstWhere((c) => c.id == id, orElse: () => mainnet);
}
