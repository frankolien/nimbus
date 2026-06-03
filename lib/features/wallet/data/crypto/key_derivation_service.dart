import 'package:blockchain_utils/blockchain_utils.dart';

import '../../domain/entities/blockchain_account.dart';
import '../../domain/entities/chain_family.dart';
import '../../domain/entities/wallet_account.dart';

/// Derives per-chain keys and addresses from a BIP39 mnemonic, following the
/// Phantom derivation scheme (account index bumps the hardened account level):
///
///   EVM      m/44'/60'/{i}'/0/0
///   Solana   m/44'/501'/{i}'/0'
///   Bitcoin  m/84'/0'/{i}'/0/0   (native SegWit, BIP84)
///   Sui      m/44'/784'/{i}'/0'/0'
///
/// Public derivation ([deriveAddress]/[deriveWalletAccount]) never returns
/// private material. Signing keys are exposed only through
/// [deriveSigningKey], which returns a transient [DerivedSigningKey] the caller
/// is responsible for using and discarding promptly.
class KeyDerivationService {
  const KeyDerivationService();

  /// All families this wallet supports, in display order.
  static const supportedFamilies = [
    ChainFamily.solana,
    ChainFamily.evm,
    ChainFamily.bitcoin,
    ChainFamily.sui,
  ];

  /// Derive the public address for a single [family] at [accountIndex].
  BlockchainAccount deriveAddress(
    String mnemonic,
    ChainFamily family,
    int accountIndex,
  ) {
    final seed = _seed(mnemonic);
    final node = _derive(seed, family, accountIndex);
    return BlockchainAccount(
      family: family,
      address: node.publicKey.toAddress,
      publicKeyHex: BytesUtils.toHexString(node.publicKey.compressed),
      derivationPath: _path(family, accountIndex),
      accountIndex: accountIndex,
    );
  }

  /// Derive one address per supported family for [accountIndex], producing a
  /// complete Phantom-style account. No private keys are retained.
  WalletAccount deriveWalletAccount(
    String mnemonic,
    int accountIndex, {
    String? label,
  }) {
    final seed = _seed(mnemonic);
    final byFamily = <ChainFamily, BlockchainAccount>{};
    for (final family in supportedFamilies) {
      final node = _derive(seed, family, accountIndex);
      byFamily[family] = BlockchainAccount(
        family: family,
        address: node.publicKey.toAddress,
        publicKeyHex: BytesUtils.toHexString(node.publicKey.compressed),
        derivationPath: _path(family, accountIndex),
        accountIndex: accountIndex,
      );
    }
    return WalletAccount(
      index: accountIndex,
      label: label ?? 'Account ${accountIndex + 1}',
      accountsByFamily: byFamily,
    );
  }

  /// Derive a transient signing key for [family] at [accountIndex].
  ///
  /// The returned object holds raw private-key bytes. Use it immediately for
  /// signing and let it go out of scope; never persist or log it.
  DerivedSigningKey deriveSigningKey(
    String mnemonic,
    ChainFamily family,
    int accountIndex,
  ) {
    final seed = _seed(mnemonic);
    final node = _derive(seed, family, accountIndex);
    return DerivedSigningKey(
      family: family,
      privateKeyBytes: List<int>.unmodifiable(node.privateKey.raw),
      address: node.publicKey.toAddress,
      derivationPath: _path(family, accountIndex),
    );
  }

  // --- internals ---

  List<int> _seed(String mnemonic) =>
      Bip39SeedGenerator(Mnemonic.fromString(mnemonic)).generate();

  /// Derive the leaf node for [family]/[accountIndex] using the Phantom path.
  Bip44Base _derive(List<int> seed, ChainFamily family, int accountIndex) {
    switch (family) {
      case ChainFamily.evm:
        return Bip44.fromSeed(seed, Bip44Coins.ethereum)
            .purpose
            .coin
            .account(accountIndex)
            .change(Bip44Changes.chainExt)
            .addressIndex(0);
      case ChainFamily.solana:
        // Solana's path is 4 levels (m/44'/501'/i'/0'); stop at change.
        return Bip44.fromSeed(seed, Bip44Coins.solana)
            .purpose
            .coin
            .account(accountIndex)
            .change(Bip44Changes.chainExt);
      case ChainFamily.bitcoin:
        return Bip84.fromSeed(seed, Bip84Coins.bitcoin)
            .purpose
            .coin
            .account(accountIndex)
            .change(Bip44Changes.chainExt)
            .addressIndex(0);
      case ChainFamily.sui:
        return Bip44.fromSeed(seed, Bip44Coins.sui)
            .purpose
            .coin
            .account(accountIndex)
            .change(Bip44Changes.chainExt)
            .addressIndex(0);
    }
  }

  /// Canonical BIP32 path string for storage/display. Kept in sync with
  /// [_derive]; covered by tests so the two can't silently diverge.
  String _path(ChainFamily family, int i) {
    switch (family) {
      case ChainFamily.evm:
        return "m/44'/60'/$i'/0/0";
      case ChainFamily.solana:
        return "m/44'/501'/$i'/0'";
      case ChainFamily.bitcoin:
        return "m/84'/0'/$i'/0/0";
      case ChainFamily.sui:
        return "m/44'/784'/$i'/0'/0'";
    }
  }
}

/// A transient bundle of private-key material for one family/account. Hold it
/// only as long as needed to sign, then let it be garbage-collected.
class DerivedSigningKey {
  DerivedSigningKey({
    required this.family,
    required this.privateKeyBytes,
    required this.address,
    required this.derivationPath,
  });

  final ChainFamily family;
  final List<int> privateKeyBytes;
  final String address;
  final String derivationPath;

  /// Private key as a 0x-free hex string. Avoid retaining the result.
  String get privateKeyHex => BytesUtils.toHexString(privateKeyBytes);

  /// Never include key material in logs or error messages.
  @override
  String toString() => 'DerivedSigningKey(${family.id}, $address)';
}
