import 'chain_family.dart';

/// A concrete blockchain network the wallet can show balances for and (later)
/// transact on. Multiple networks can share the same [ChainFamily] address —
/// e.g. Ethereum, Polygon and Base all use the single EVM address.
///
/// `rpcEnvKey` names the entry in `.env` that holds this network's RPC URL (or
/// an API key used to build one); resolution happens in the data layer so the
/// domain stays configuration-free.
enum Network {
  ethereum(
    id: 'ethereum',
    displayName: 'Ethereum',
    family: ChainFamily.evm,
    nativeSymbol: 'ETH',
    nativeDecimals: 18,
    evmChainId: 1,
    rpcEnvKey: 'ETHEREUM_RPC_URL',
    explorerBaseUrl: 'https://etherscan.io',
  ),
  polygon(
    id: 'polygon',
    displayName: 'Polygon',
    family: ChainFamily.evm,
    nativeSymbol: 'POL',
    nativeDecimals: 18,
    evmChainId: 137,
    rpcEnvKey: 'POLYGON_RPC_URL',
    explorerBaseUrl: 'https://polygonscan.com',
  ),
  base(
    id: 'base',
    displayName: 'Base',
    family: ChainFamily.evm,
    nativeSymbol: 'ETH',
    nativeDecimals: 18,
    evmChainId: 8453,
    rpcEnvKey: 'BASE_RPC_URL',
    explorerBaseUrl: 'https://basescan.org',
  ),
  solana(
    id: 'solana',
    displayName: 'Solana',
    family: ChainFamily.solana,
    nativeSymbol: 'SOL',
    nativeDecimals: 9,
    evmChainId: null,
    rpcEnvKey: 'SOLANA_RPC_URL',
    explorerBaseUrl: 'https://solscan.io',
  ),
  bitcoin(
    id: 'bitcoin',
    displayName: 'Bitcoin',
    family: ChainFamily.bitcoin,
    nativeSymbol: 'BTC',
    nativeDecimals: 8,
    evmChainId: null,
    rpcEnvKey: 'BITCOIN_RPC_URL',
    explorerBaseUrl: 'https://mempool.space',
  ),
  sui(
    id: 'sui',
    displayName: 'Sui',
    family: ChainFamily.sui,
    nativeSymbol: 'SUI',
    nativeDecimals: 9,
    evmChainId: null,
    rpcEnvKey: 'SUI_RPC_URL',
    explorerBaseUrl: 'https://suiscan.xyz',
  );

  const Network({
    required this.id,
    required this.displayName,
    required this.family,
    required this.nativeSymbol,
    required this.nativeDecimals,
    required this.evmChainId,
    required this.rpcEnvKey,
    required this.explorerBaseUrl,
  });

  /// Stable identifier for storage/serialization. Never change.
  final String id;
  final String displayName;
  final ChainFamily family;

  /// Ticker of the network's native asset (ETH, SOL, BTC, …).
  final String nativeSymbol;

  /// Decimal places of the native asset's smallest unit.
  final int nativeDecimals;

  /// EVM chain id, or null for non-EVM networks.
  final int? evmChainId;

  /// `.env` key holding this network's RPC endpoint.
  final String rpcEnvKey;

  /// Block explorer base URL (used to build address/tx links).
  final String explorerBaseUrl;

  bool get isEvm => family == ChainFamily.evm;

  /// All networks belonging to [family].
  static List<Network> forFamily(ChainFamily family) =>
      values.where((n) => n.family == family).toList();

  static Network fromId(String id) =>
      values.firstWhere((n) => n.id == id, orElse: () {
        throw ArgumentError('Unknown Network id: $id');
      });
}
