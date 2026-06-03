/// A *chain family* groups blockchains that share the same key-derivation
/// scheme. One derived key per family produces a single address that is valid
/// across every [Network] in that family.
///
/// This mirrors the Phantom model: a single recovery phrase yields one EVM
/// address (usable on Ethereum, Polygon, Base, …), one Solana address, one
/// Bitcoin address, and one Sui address.
///
/// The concrete mapping from a family to a derivation library lives in the
/// data/crypto layer; this enum stays free of any crypto dependency so the
/// domain remains pure and testable.
enum ChainFamily {
  /// secp256k1, BIP44 path m/44'/60'/0'/0/index. Shared by all EVM networks.
  evm(
    id: 'evm',
    displayName: 'Ethereum & EVM',
    curve: KeyCurve.secp256k1,
    coinType: 60,
  ),

  /// ed25519 (SLIP-0010), path m/44'/501'/index'/0'. Phantom's flagship chain.
  solana(
    id: 'solana',
    displayName: 'Solana',
    curve: KeyCurve.ed25519,
    coinType: 501,
  ),

  /// secp256k1 native SegWit (BIP84), path m/84'/0'/0'/0/index.
  bitcoin(
    id: 'bitcoin',
    displayName: 'Bitcoin',
    curve: KeyCurve.secp256k1,
    coinType: 0,
  ),

  /// ed25519, path m/44'/784'/index'/0'/0'. Address = blake2b of flag+pubkey.
  sui(
    id: 'sui',
    displayName: 'Sui',
    curve: KeyCurve.ed25519,
    coinType: 784,
  );

  const ChainFamily({
    required this.id,
    required this.displayName,
    required this.curve,
    required this.coinType,
  });

  /// Stable identifier used for storage keys and serialization. Never change
  /// these values — persisted data and derivation paths depend on them.
  final String id;

  /// Human-readable label for UI.
  final String displayName;

  /// Elliptic curve used for this family's keys.
  final KeyCurve curve;

  /// BIP44 coin type (the second path component, hardened).
  final int coinType;

  static ChainFamily fromId(String id) =>
      values.firstWhere((f) => f.id == id, orElse: () {
        throw ArgumentError('Unknown ChainFamily id: $id');
      });
}

/// Elliptic curve used for key derivation.
enum KeyCurve { secp256k1, ed25519 }
