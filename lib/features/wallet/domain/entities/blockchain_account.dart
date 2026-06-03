import 'package:equatable/equatable.dart';

import 'chain_family.dart';

/// A single address derived for one [ChainFamily] at a specific account index.
///
/// Deliberately holds **no private key**. Private keys never leave the crypto
/// layer except transiently for signing; entities, state, and persistence only
/// ever carry public material.
class BlockchainAccount extends Equatable {
  const BlockchainAccount({
    required this.family,
    required this.address,
    required this.publicKeyHex,
    required this.derivationPath,
    required this.accountIndex,
  });

  final ChainFamily family;

  /// The chain-native, display-ready address (checksummed EVM, base58 Solana,
  /// bech32 Bitcoin, 0x-hex Sui).
  final String address;

  /// Hex-encoded public key (no `0x` prefix), for signature verification and
  /// chains that address by public key.
  final String publicKeyHex;

  /// Full BIP32 derivation path this address came from, e.g. m/44'/60'/0'/0/0.
  final String derivationPath;

  /// The Phantom-style account index this address belongs to (0-based).
  final int accountIndex;

  @override
  List<Object?> get props =>
      [family, address, publicKeyHex, derivationPath, accountIndex];

  Map<String, dynamic> toJson() => {
        'family': family.id,
        'address': address,
        'publicKeyHex': publicKeyHex,
        'derivationPath': derivationPath,
        'accountIndex': accountIndex,
      };

  factory BlockchainAccount.fromJson(Map<String, dynamic> json) =>
      BlockchainAccount(
        family: ChainFamily.fromId(json['family'] as String),
        address: json['address'] as String,
        publicKeyHex: json['publicKeyHex'] as String,
        derivationPath: json['derivationPath'] as String,
        accountIndex: json['accountIndex'] as int,
      );
}
